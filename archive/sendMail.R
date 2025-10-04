#sendMail.R

library(gmailr)

# construct a simple text only message ------------------------------------

text_msg <- mime() %>%
  to("phongevelyn@yahoo.com") %>%
  from("hamdan.hy@gmail.com") %>%
  subject("News of the Hour -- send from within R") %>%
  text_body("For your attention") 


# message to a properly formatted MIME
# text_msg <- strwrap(as.character(text_msg))


# Add attachments ---------------------------------------------------------

file_attachment <- text_msg %>%
    attach_file("newsClipbySectionV3.docx")

# Create Draft ------------------------------------------------------------
# auth code: 4/7JITZJi8rTnYg0gCj5WFntLqKV9yjY5L4kkdPi9KZ0w
# create_draft(text_msg)

# Send --------------------------------------------------------------------

send_message(file_attachment)
unlink("newsClipbySectionV2.1.docx")
