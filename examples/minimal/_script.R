library(tidyverse)

set.seed(1)
data <- tibble(
  id = LETTERS[1:10],
  text = paste0("item ", id),
  bar = 0, # to be computed afterwards
  circle = rnorm(10),
  funkyrect = rgeom(10, .1),
  image = sample(c("one", "two", "three"), 10, replace = TRUE),
  pie = lapply(seq_len(10), function(i) {
    setNames(runif(4), letters[1:4])
  }),
  rect = rbinom(10, 100, .1)
) %>%
  mutate(
    bar = circle * funkyrect * rect
  ) %>%
  arrange(desc(bar))
column_info <- tribble(
  # tribble_start
  ~id,          ~name,           ~geom,        ~group,         ~palette,       ~options,
  "text",       "Text",          "text",       "first",        NA_character_,  list(width = 3),
  #,            "image",         "Image",      "image",        "first",        list(),
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
palettes <- list(
  first = funkyheatmap:::default_palettes$numerical$Greys,
  second = funkyheatmap:::default_palettes$numerical$Blues,
  third = funkyheatmap:::default_palettes$numerical$Reds,
  fourth = funkyheatmap:::default_palettes$numerical$Greens,
  third_cat = setNames(funkyheatmap:::default_palettes$categorical$Set3[1:4], c("A", "B", "C", "D"))
)

funkyheatmap::funky_heatmap(
  data = data,
  column_info = column_info,
  column_groups = column_groups,
  palettes = palettes
)
