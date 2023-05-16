library(tibble)
library(dplyr)
library(tidyr)
library(purrr)

set.seed(1)

# create data
data <- tibble(
  id = LETTERS[1:11],
  text1 = paste0("prop", id),
  text2 = paste0("property of ", id),
  numerical1 = seq(0, 1, length.out = 11),
  numerical2 = seq(10L, 20L, length.out = 11),
  numerical3 = seq(0, .1, length.out = 11),
  numerical1_str = sprintf("%.1f", numerical1),
  numerical2_str = sprintf("%i", numerical2),
  numerical3_str = sprintf("%.2f", numerical3),
  categories1 = lapply(
    numerical1,
    function(a) {
      c("foo" = 1 - a, "bar" = a / 3, "zing" = 2 * a / 3)
    }
  ),
  categories2 = lapply(
    numerical2,
    function(a) {
      c("foo" = a, "bar" = a * 2, "zing" = a * 3)
    }
  ),
  categories3 = lapply(
    numerical3,
    function(a) {
      c("foo" = a + .0001, "bar" = a^2 + a / 2, "zing" = a^3 + a / 3)
    }
  )
)

# create column info

# todo: add image
    # "image",      "Image",         "image",      "first",        NA_character_,  list(directory = "images/", extension = ".png"),
column_info <- tribble(
  # tribble_start
  ~id,            ~name,          ~geom,        ~group,         ~palette,        ~options,
  "id",           "",             "text",       "text",         NA_character_,   list(width = 1),
  "text1",        "Text 1",       "text",       "text",         NA_character_,   list(width = 3),
  "text2",        "Text 2",       "text",       "text",         NA_character_,   list(width = 4),
  "numerical1",   "Bar 1",        "bar",        "bar",          "bar",           list(width = 2),
  "numerical2",   "Bar 2",        "bar",        "bar",          "bar",           list(width = 2),
  "numerical3",   "Bar 3",        "bar",        "bar",          "bar",           list(width = 2),
  "numerical1",   "Circle 1",     "circle",     "circle",       "circle",        list(),
  "numerical2",   "Circle 2",     "circle",     "circle",       "circle",        list(),
  "numerical3",   "Circle 3",     "circle",     "circle",       "circle",        list(),
  "numerical1",   "FunkyRect 1",  "funkyrect",  "funkyrect",    "funkyrect",     list(),
  "numerical2",   "FunkyRect 2",  "funkyrect",  "funkyrect",    "funkyrect",     list(),
  "numerical3",   "FunkyRect 3",  "funkyrect",  "funkyrect",    "funkyrect",     list(),
  "numerical1",   "Rect 1",       "rect",       "rect",         "rect",          list(),
  "numerical1",   "",             "text",       NA_character_,  "black6white4",  list(label = "numerical1_str", overlay = TRUE),
  "numerical2",   "Rect 2",       "rect",       "rect",         "rect",          list(),
  "numerical2",   "",             "text",       NA_character_,  "black6white4",  list(label = "numerical2_str", overlay = TRUE),
  "numerical3",   "Rect 3",       "rect",       "rect",         "rect",          list(),
  "numerical3",   "",             "text",       NA_character_,  "black6white4",  list(label = "numerical3_str", overlay = TRUE),
  "categories1",  "Pie 1",        "pie",        "pie",          "pie",           list(),
  "categories2",  "Pie 2",        "pie",        "pie",          "pie",           list(),
  "categories3",  "Pie 3",        "pie",        "pie",          "pie",           list()
  # tribble_end
) %>%
  mutate(options = map(options, function(x) {
    if (length(x) == 0) {
      tibble(a = 1)[, -1, drop = FALSE]
    } else {
      as_tibble(x)
    }
  })) %>%
  unnest(cols = "options")
column_groups <- tribble(
  # tribble_start
  ~group,       ~palette,     ~level1,
  "text",       "text",       "Text",
  "bar",        "bar",        "Bars",
  "circle",     "circle",     "Circles",
  "funkyrect",  "funkyrect",  "FunkyRects",
  "rect",       "rect",       "Rects",
  "pie",        "pie",        "Pies"
  # tribble_end
)

# row data structures
row_info <- tibble(
  group = c(rep("A-D", 4), rep("E-G", 3), rep("H-K", 4)),
  id = LETTERS[1:11]
)
row_groups <- tribble(
  ~group, ~Group,
  "A-D", "from A to D",
  "E-G", "from E to G",
  "H-K", "from H to K"
)

# palettes
palettes <- list(
  text = funkyheatmap:::default_palettes$numerical$Greys,
  bar = funkyheatmap:::default_palettes$numerical$Blues,
  circle = funkyheatmap:::default_palettes$numerical$Reds,
  funkyrect = funkyheatmap:::default_palettes$numerical$YlOrBr,
  rect = funkyheatmap:::default_palettes$numerical$Greens,
  pie = setNames(funkyheatmap:::default_palettes$categorical$Set3[1:3], c("foo", "bar", "zing")),
  black6white4 = c(rep("white", 4), rep("black", 6))
)

# create dir if not exists
data_dir <- "examples/minimal/data"
if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

# tweak data formats before writing them to file
data_write <- data %>% mutate_at(
  c("categories1", "categories2", "categories3"),
  function(column) {
    sapply(column, function(val) {
      as.character(jsonlite::toJSON(as.list(val), auto_unbox = TRUE))
    })
  }
)
palettes_write <- palettes
palettes_write$pie <- as.list(palettes$pie)

# write to files
readr::write_tsv(data_write, paste0(data_dir, "/data.tsv"), quote = "all")
readr::write_tsv(column_info, paste0(data_dir, "/column_info.tsv"), quote = "all") # todo: fix options
readr::write_tsv(column_groups, paste0(data_dir, "/column_groups.tsv"), quote = "all")
readr::write_tsv(row_info, paste0(data_dir, "/row_info.tsv"), quote = "all")
readr::write_tsv(row_groups, paste0(data_dir, "/row_groups.tsv"), quote = "all")
jsonlite::write_json(
  palettes_write,
  paste0(data_dir, "/palettes.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

# preview
funkyheatmap::funky_heatmap(
  data = data,
  column_info = column_info,
  column_groups = column_groups,
  row_info = row_info,
  row_groups = row_groups,
  palettes = palettes
)
