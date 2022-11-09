#newsMail.R1

library(gmailr)

# construct a simple text only message ------------------------------------

body <- "As salam, For your attention. Thanks."
text_msg <- mime() %>%
  to("hy.mpa@mod.gov.my") %>%
  from("hamdan.hy@gmail.com") %>%
  subject("News of the Hour -- For your attention") %>%
  text_body(body) %>%
  attach_part(body) %>%
  attach_file("newsdaily.RData") %>%
  attach_file("newsDailyKPI.RData") %>% 
  attach_file("daily.RData")

# message to a properly formatted MIME
# text_msg <- strwrap(as.character(text_msg))

# Add attachments ---------------------------------------------------------

# file_attachment <- text_msg %>%
#   attach_file("newsClipbySection.docx")

# Create Draft ------------------------------------------------------------
# auth code: 4/7JITZJi8rTnYg0gCj5WFntLqKV9yjY5L4kkdPi9KZ0w
# create_draft(text_msg)

# Send --------------------------------------------------------------------

send_message(text_msg)
# unlink("newsClipbySection.html")
