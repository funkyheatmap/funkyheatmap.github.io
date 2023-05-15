library(tibble)
library(dplyr)

set.seed(1)

# create MRE
data <- tibble(
  id = LETTERS[1:10],
  text = paste0("item ", id),
  bar = 0, # to be computed afterwards
  circle = rnorm(10),
  funkyrect = rgeom(10, .1),
  image = sample(c("one", "two", "three"), 10, replace = TRUE),
  pie = lapply(seq_len(10), function(i) {
    setNames(runif(4), LETTERS[1:4])
  }),
  rect = rbinom(10, 100, .1)
) %>%
  mutate(
    bar = circle * funkyrect * rect
  ) %>%
  arrange(desc(bar))

# create column info
column_info <- tribble(
  # tribble_start
  ~id,          ~name,           ~geom,        ~group,         ~palette,       ~options,
  "text",       "Text",          "text",       "first",        NA_character_,  list(width = 3),
  # "image",      "Image",         "image",      "first",        NA_character_,  list(directory = "images/", extension = ".png"),
  "image",      "Image",         "text",       "first",        NA_character_,  list(width = 2),
  "bar",        "Bar",           "bar",        "second",       "second",       list(width = 2),
  "circle",     "Circle",        "circle",     "second",       "second",       list(),
  "funkyrect",  "FunkyRect",     "funkyrect",  "second",       "second",       list(),
  "rect",       "Rect",          "rect",       "third",        "third",        list(),
  "pie",        "Pie",           "pie",        "third",        "third_cat",    list(),
  "rect",       "Text-on-rect",  "rect",       "fourth",       "fourth",       list(),
  "id",         "",              "text",       NA_character_,  NA_character_,  list(overlay = TRUE)
  # tribble_end
)
column_groups <- tribble(
  # tribble_start
  ~group,    ~palette,  ~level1,
  "first",   "first",   "First",
  "second",  "second",  "Second",
  "third",   "third",   "Third",
  "fourth",  "fourth",  "Fourth"
  # tribble_end
)
row_info <- tibble(
  group = c(rep("A-D", 4), rep("E-G", 3), rep("H-J", 3)),
  id = LETTERS[1:10]
)
# row_groups <- tribble(
#   ~group, ~Group, ~GROUP,
#   "A-D", "from A to D", "LETTERS",
#   "E-G", "from E to G", "LETTERS",
#   "H-J", "from H to J", "LETTERS",
# )
row_groups <- tribble(
  ~group, ~Group,
  "A-D", "from A to D",
  "E-G", "from E to G",
  "H-J", "from H to J"
)
palettes <- list(
  first = funkyheatmap:::default_palettes$numerical$Greys,
  second = funkyheatmap:::default_palettes$numerical$Blues,
  third = funkyheatmap:::default_palettes$numerical$Reds,
  fourth = funkyheatmap:::default_palettes$numerical$Greens,
  third_cat = setNames(funkyheatmap:::default_palettes$categorical$Set3[1:4], c("A", "B", "C", "D"))
)

data_dir <- "examples/minimal/data"
if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

readr::write_tsv(data, paste0(data_dir, "/data.tsv"))
readr::write_tsv(column_info, paste0(data_dir, "/column_info.tsv")) # todo: fix options
readr::write_tsv(column_groups, paste0(data_dir, "/column_groups.tsv"))
readr::write_tsv(row_info, paste0(data_dir, "/row_info.tsv"))
readr::write_tsv(row_groups, paste0(data_dir, "/row_groups.tsv"))
jsonlite::write_json(palettes, paste0(data_dir, "/palettes.json"))

funkyheatmap::funky_heatmap(
  data = data,
  column_info = column_info,
  column_groups = column_groups,
  row_info = row_info,
  row_groups = row_groups,
  palettes = palettes
)
