library(readr)
library(stringr)
library(cli)
library(purrr)
library(googledrive)

cli::cli_alert("google drive authentication")
zip_file <- fs::path_wd("paper/auth_token.zip")
auth_file <- paste0(Sys.getenv("HOME"), "/.cache/gargle/134f22af3ae3a9f0b7f0eb57dd61916f_", Sys.getenv("GOOGLE_DRIVE_EMAIL"))

# zip_file created with:
  # processx::run(
  #   "zip",
  #   args = c(zip_file, basename(auth_file), "--password", Sys.getenv("GOOGLE_DRIVE_PASSWORD")),
  #   wd = dirname(auth_file)
  # )

if (is.null(Sys.getenv("GOOGLE_DRIVE_EMAIL"))) {
  stop("Need the email to authenticate")
}

if (!file.exists(auth_file)) {
  if (is.null(Sys.getenv("GOOGLE_DRIVE_PASSWORD"))) {
    stop("Need the password to unzip")
  }
  dir.create(dirname(auth_file), recursive = TRUE, showWarnings = FALSE)
  processx::run("unzip", c("-D", "-P", Sys.getenv("GOOGLE_DRIVE_PASSWORD"), zip_file), wd = dirname(auth_file))
}

googledrive::drive_auth(email = Sys.getenv("GOOGLE_DRIVE_EMAIL"), path = auth_file)

cli::cli_alert("download paper from gdrive")
temp_paper <- tempfile()
dest_paper <- "paper/index.qmd"
dest_library <- "paper/library.bib"

drive <- drive_download(
  as_id("1bQRWcRk8bgoYQA-CBynXgbFO9MU-mLdQBehX5lIEqeY"),
  type = "docx",
  overwrite = TRUE,
  path = temp_paper
)

cli::cli_alert("read docx and write to qmd")
doc <- officer::read_docx(drive$local_path)
content <- officer::docx_summary(doc)

content$text %>%
  # add spaces before citations
  # str_replace_all("([^ ])(\\[@[^\\]]*\\])", "\\1 \\2") %>% 
  # add newlines before sections
  str_replace_all("^(#+ )", "\n\\1") %>%
  write_lines(dest_paper)


cli::cli_alert("extract citation yaml")
manu_txt <- read_lines(dest_paper) %>% paste(collapse = "\n")
citations_yaml <- gsub(".*```\\{citations[^\n]*\n([^`]*)```.*", "\\1", manu_txt)
citations <- yaml::read_yaml(text = citations_yaml)$citations


bibtexhandle <- curl::new_handle()
curl::handle_setheaders(bibtexhandle, "accept" = "application/x-bibtex")

cli::cli_alert("convert to bibtex")
bibs <- map2_chr(names(citations), citations, function(name, text) {
  bib <-
    if (grepl("^@", text)) {
      # text is already a bibtex, update citation key
      text
    } else {
      url <- paste0("https://doi.org/", text)
      res <- curl::curl_fetch_memory(url, handle = bibtexhandle)
      if (res$status_code != 200) {
        cli::cli_alert_warning(paste0("Error processing doi '", text, "'"))
        ""
      } else {
        rawToChar(res$content)
      }
    }
  bib %>%
    gsub("(@[^\\{]+\\{)[^,]*,", paste0("\\1", name, ","), .) %>%
    gsub("\\{\\\\&\\}amp\\$\\\\mathsemicolon\\$", "{\\\\&}", .)
})

cli::cli_alert("write library file")
write_lines(bibs, dest_library)