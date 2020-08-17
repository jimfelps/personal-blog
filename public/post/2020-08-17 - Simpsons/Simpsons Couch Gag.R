library(tidyverse)
library(rvest)
library(ggwaffle)
library(magick)

# helper function to rename columns in all df's
renameList<-function(x,some_names){
  names(x) <- some_names
  return(x)
}
# uniform names for columns
some_names <- c("#", "air_date", "screenshot", "gag", "episode", "code")

# site to scrap data from
website <- "https://simpsons.fandom.com/wiki/List_of_couch_gags"

# scrap table data from site--only <table> nodes are for data that I want
tables <- website %>% 
  read_html() %>% 
  html_nodes("table") %>% 
  html_table(fill = TRUE) #needs to be passed to html_table before we can rind_rows (list of vectors vs list of tables, I think)

# rename all columns in list of data frames to match. 
# Early seasons use "Gag Name" while later seasons use "Gag" which will mess up combining into one
same_cols_tables <- lapply(tables, renameList, some_names)

# combine all seasons into one dataframe
all_episodes <- bind_rows(same_cols_tables, .id = "season")

# categorize couch gags based on gag field. Repeats are consistent but no gag has a two variants
all_episodes %>% 
  mutate(gag_cat = if_else(str_detect(gag, regex("repeat of", ignore_case = TRUE)), "Repeat",
                           if_else(str_detect(gag, regex("none", ignore_case = TRUE)), "None",
                           if_else(str_detect(gag, regex("no gag", ignore_case = TRUE)), "None",
                           if_else(str_detect(gag, "TBA"), "None",
                                   "Original")))),
         no_gag = if_else(gag_cat == "None", 1, 0)) %>% 
  group_by(season) %>% 
  mutate(season_episode = row_number(),
         season = as.numeric(season)) %>% 
  select(-screenshot) %>% 
  ungroup() -> all_episodes

# I spot checked this against the Reddit post and it looks close. Filtering for none's and I noticed one that stuck out
# Episode 108 lists a repeat but also no gag. From what I understand, the original airing had a repeat but subseqent airings 
# did not have a gag.


# Look at count of gags to see which repeats the most. I have a clue from the comments
# Maybe make a bar chart of just the repeats. Nothing fancy.
most_repeats <-  all_episodes %>% 
  count(gag, sort = TRUE) %>% 
  filter(str_detect(gag, regex("repeat ", ignore_case = TRUE)),
         n > 1)
# are there more intros w/o couch gags in recent seasons?

no_gag <- all_episodes %>% 
  group_by(season) %>% 
  summarise(percent_none = sum(no_gag)/max(season_episode))

no_gag %>% 
  ggplot(aes(season, percent_none)) +
  geom_line() +
  theme_minimal() +
  labs(
    x = "Season",
    y = "",
    title = "Percent of Episodes with no Couch Gag by Season"
  ) -> no_gag_plot
  
ggsave("static/img/simpsons/percent_no_gag.png",
         plot = last_plot(),
         width = 16, 
         height = 9, 
         dpi = "retina")

theme_update(
  panel.grid = element_blank(),
  panel.border = element_blank(),
  panel.background = element_rect(fill = "#f8db63",
                                  color = "#f8db63"),
  axis.text = element_text(size = 10),
  axis.ticks = element_blank(),
  axis.line = element_blank(),
  axis.ticks.length = unit(0, "null"),
  plot.background = element_rect(fill = "#f8db63"),
  panel.spacing = unit(c(0,0, 0, 0), "null"),
  legend.background = element_rect(fill = "#f8db63"),
  legend.key = element_rect(fill = "#f8db63"))
#F7CAC9 rose quartz 
# visualize 
p <- all_episodes %>% 
  ggplot(aes(season_episode, reorder(season, -season), fill = gag_cat)) +
  geom_waffle(color = "#afaeae", size = 0.75) +
  coord_equal() +
  labs(
    x = "Episode",
    y = "Season",
    title = "",
    subtitle = "",
    caption = "Data: https://simpsons.fandom.com/wiki/List_of_couch_gags\nVisual: Jim Felps (@Calvinchoice)") +
  scale_x_continuous(breaks = seq(from = 1, to = max(all_episodes$season_episode), by = 1),
                     position = "top") +
  theme(legend.title = element_blank()) +
  scale_fill_manual(values = c("#fed41d", "#f14e28", "#009ddc")) 

# save as image
ggsave("static/img/simpsons/couch_gag_visual.png", 
       p, 
       width = 16, 
       height = 9, 
       dpi = "retina")

# import Simpsons logo from Wikipedia (I don't think this is illegal but I'll review Wikipedia before posting)
simp_logo <- image_read("https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/The_Simpsons_Logo.svg/1024px-The_Simpsons_Logo.svg.png")

# bring back the plot
simp_plot <- image_read("static/img/simpsons/couch_gag_visual.png") %>% 
  image_trim()
  

# annotate simpsons logo with faux simpsons font (font I found wasn't very good honestly)
# based on original found on Reddit, this is the font they used as well
simp_logo_text <- simp_logo %>%
  image_background("#f8db63", flatten = TRUE) %>% 
  image_border(color = "#f8db63", "400x0") %>% 
  image_scale("1024") %>% 
  image_annotate("\nCouch Gags", color = "#EB3333",
                 size = 40, gravity = "south", font = "Bradley Hand ITC")

final_plot <- image_append(image_scale(c(simp_logo_text, simp_plot), "1024"), 
                           stack = TRUE)
image_write(final_plot, "static/img/simpsons/final_plot.png", format = "png")

# think I found a better way to handle then grid/gtable -------------------------

# import simpsons logo for visual
#simp_logo <- png::readPNG("static/img/simpsons/1024px-The_Simpsons_Logo.svg.png") %>% 
#  rasterGrob(interpolate = TRUE)
#
## convert ggplot to grob
#gt <- ggplotGrob(p)
#
#new_title <- gtable(widths = grobWidth(gt),
#                    heights = grobHeight(gt)) %>% 
#  gtable_add_grob(grobs = simp_logo, t = 1, l = 1)
#
#gt$grobs[[which(gt$layout$name == "title")]] <- new_title
#
#grid.draw(gt)
