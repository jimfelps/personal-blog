---
title: How Frequently Do The Simpsons Repeat Couch Gags?
author: Jim
date: '2020-08-17'
slug: simpsons-couch-gag
categories:
  - python conversion
  - R
tags:
  - Simpsons
bigimg:
- desc: 
  src: /img/simpsons/fan-art-1140718.png
type: ''
subtitle: ''
image: ''
---

While trying to figure out what content to include on this site, I decided it might be best to start re-creating visualizations found online. I looked through the subreddit /r/dataisbeautiful to find a visualization, and specifically one done in a language other than R, that I found appealing and the subject matter interesting. I look at this subreddit a few times each month and love the work that people post. I like that this subreddit contains visualizations from people that have been perfecting their craft for years and people just starting out.

Last weekend, I discovered [this visualization](https://www.reddit.com/r/dataisbeautiful/comments/i6if4h/oc_the_simpsons_couch_gags/) that categorizes the couch gigs at the beginning of each episode into "Original", "Repeat" or "None" based on data from a Simpsons fan wiki [here](https://simpsons.fandom.com/wiki/List_of_couch_gags). The creator did this visualization did a fantastic job with colors while also keeping it simple. According to the comments, the author created this in Python and Excel but provided no code (looks like Python was only used for web scraping, Excel was used to create the visual), which is perfect for my purpose. I can't rely on the published work of others to recreate this visual in R. So, given the data source and nothing more, here's my attempt while learning along the way.

I've seen a bunch of Simpsons episodes over the years, but wouldn't say I'm a big fan of the series. I believe my brother and I were barred from watching episodes during the first few seasons (probably age more than anything) but our parents eventually relaxed the rules and allowed us to watch.  I always enjoyed the show but my brother was a bigger fan. It's been several years since I've seen an episode in full and I was surprised to learn that they are still making new episodes. Season 31 just ended and there are plans for a 32nd season. Crazy.

Before getting into my planning and execution, here's the final plot:

![](/img/simpsons/final_plot.png)

## Planning the Plot

First thing to do is figure out what to keep and what stays. The logo and colors seem like natural fits to keep. I didn't like the dark boxes around season and episode tally and I'm not even sure how I would go about doing this in ggplot2 so those will be removed from my version. 

To scrap the data from the Simpsons fan wiki, I used the Rvest package. This is my first experience with the package and found it super simple to use. The data is stored in HTML tables, so after passing the website to the ```read_html()``` function, I just needed to add "table" to the ```html_nodes()``` function, which just pulls any data between <table> tags. Pass this to ```html_table()``` so the resulting list contains tables of each season. 

The only real issue I had with the data once I pulled it into my R session was inconsistent column names. After the table for Season 2, the wiki changed the column name for gag description from "Gag Name" to "Gag". The episode number had a leading ">" in Season 28. The inconsistent naming caused problems when I combine the seasons into one dataframe, so I had to change the names to match each other prior to forming one table.

I wasn't sure how to add an image to top of a ggplot plot, but after doing a bit of reading online it seemed possible by using the {magick} package. If there's a better way I would like to know, but this wasn't terribly difficult. I found a Simpsons font to use for the couch gag text but I didn't think it looked right. Bradley Hand ITC is the font I used and after comparing to the original, I'm convinced u/DBails also used this font.

## Data Insights

Final count is slightly different than u/DBails due to two episodes that we have categorized differently.

*None: 73

*Original: 424

*Repeat: 186

Episode 108 (S6E5) was categorized as "None" on the Reddit creation while I categorized this as "Repeat". According to the fan wiki:

>repeat of 1F06's gag (first airing)/no gag (repeats)

So the original airing had a repeat of the episode 89 (S5E8) couch gag but repeats do not have a couch gag. None or Repeat work here but I chose Repeat.

The fan wiki has not been updated with info on the final three episodes of season 31, so it shows TBA for these couch gags. I categorized each of these as None while the Reddit user categorized two of these as None and one as Original (Episode 682, S31E20). Looks to be an error.

The most repeated couch gag is the chorus line gag below:

{{< youtube v5fLEuGLDM0 >}}


This is also the longest couch gag, which is apparently why it gets reused so much (7 times). According to a comment in the Reddit thread above, this couch gag gets used when they need to extend an episode that is running short.

The use of repeat couch gags was common for the final episodes in seasons 1 through 19 but from season 20 on, it appears that the producers preferred to have no couch gag using a repeat. Nearly half the intros in the most recent season have no gag.

![](/img/simpsons/percent_no_gag.png)

This visualization was fun to put together and makes me want to go back and watch/re-watch The Simpsons since they're available on Disney+. With 683 episodes available and ~30 minutes a piece, that should provide around 14 days of content. 
 
