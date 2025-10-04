#newsMail2Paul.R

library(gmailr)

# construct a simple text only message ------------------------------------

text_msg <- mime() %>%
  to("hamdan.hy@gmail.com") %>%
  from("hy.mpa@mod.gov.my") %>%
  subject("News of the Hour -- send from within R") %>%
  text_body("For your attention") 

# message to a properly formatted MIME
# text_msg <- strwrap(as.character(text_msg))

# Add attachments ---------------------------------------------------------

file_attachment <- text_msg %>%
  attach_file("newsdaily.RData") %>%
  attach_file("newsDailyKPI.RData") %>% 
  attach_file("daily.RData")

# Create Draft ------------------------------------------------------------
# auth code: 4/7JITZJi8rTnYg0gCj5WFntLqKV9yjY5L4kkdPi9KZ0w
# create_draft(text_msg)

# Send --------------------------------------------------------------------

send_message(file_attachment)
