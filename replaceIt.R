library(dplyr)
library(stringr)

t <- c("Better to tax high-sugar food instead of soda only, think tanks say::Malaysia is considering a tax on soft drinks, but it may not be enough to push Malaysians to reduce their sugar consumption. <U+2015> Bernama picKUALA LUMPUR, Sept 4 <U+2015> Malaysia may have limited success in fighting obesity and related health problems if only soft drinks are taxed as consumers can still imbibe other food and beverages with high sugar content, several research outfits said. googletag.cmd.push(function() { googletag.display(‘mm-story-320x100’); }); ")

stringr::str_replace_all(t, pattern = "googletag.cmd.push\\(function\\(\\) \\{ googletag.display\\(‘div-gpt-ad-1471855201557-0’\\)", "")
stringr::str_replace_all(t, pattern = "googletag.cmd.push\\(function\\(\\) \\{ googletag.display\\(‘mm-story-320x100’\\)\\; \\}\\)", "")
stringr::str_replace_all(t, pattern = "<U|\\+2015>","")
