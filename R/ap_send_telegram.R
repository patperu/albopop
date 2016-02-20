#' Send a message via Telegram
#'
#' Send a message via Telegram
#' @param text_msg character Message to send
#' @param TELEGRAM_TOKEN character Telegram Token
#' @param TELEGRAM_CHAT_ID character Telegram Chat_id
#' @export
ap_send_telegram <- function(text_msg, TELEGRAM_TOKEN, TELEGRAM_CHAT_ID) {

  tg_token <- Sys.getenv(TELEGRAM_TOKEN)
  if (identical(tg_token, ""))
     stop("Please define TELEGRAM_TOKEN env var", call. = FALSE)

  tg_chat_id <- Sys.getenv(TELEGRAM_CHAT_ID)
  if (identical(tg_chat_id, ""))
     stop("Please define TELEGRAM_CHAT_ID env var", call. = FALSE)

  bot_url <- file.path(paste0("https://api.telegram.org/bot", tg_token), "sendMessage")
  bot_url <- paste0(bot_url, "?chat_id=", tg_chat_id)

  invisible(x <- httr::POST(bot_url, body = list(text = text_msg)))
  if(x$status_code == 200) cat("Message was sent")

}
