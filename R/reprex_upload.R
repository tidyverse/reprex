#' Upload reprex as gist
#'
#' Uses [`gh::gh()`] to upload a reprex to GitHub gists.
#'
#' @param reprex character: reprex as created by [`reprex()`]
#' @inheritDotParams gh::gh
#' @param gist_description character: description of gist, default ""
#' @param file_name character: file_name to create, default NULL will generate
#' random filename
#' @param public boolean: whether to make gist public, default TRUE
#'
#' @seealso <https://docs.github.com/en/rest/gists/gists?apiVersion=2022-11-28#create-a-gist>
#' @family upload
#'
#' @examplesIf interactive()
#' reprex(print(pi), html_preview = FALSE) |>
#'   upload_gist()
#'
#' @return uploads to GitHub gist and invisibly returns URL of created gist
#' @export
upload_gist <- function(
  reprex,
  ...,
  gist_description = "",
  file_name = NULL,
  public = TRUE
) {
  rlang::check_installed("gh")

  if (is.null(file_name)) {
    file_name <- paste0(
      format(Sys.Date(), format = "%Y%m%d"),
      "_",
      sample(adjective_animal, 1),
      ".R"
    )
  }

  stopifnot(
    is.character(reprex) && length(reprex) > 0,
    is_string(file_name),
    is_string(gist_description),
    is_bool(public)
  )

  gist_info <- gh::gh(
    "POST /gists",
    public = public,
    description = gist_description,
    files = setNames(
      list(list(content = paste(reprex, collapse = "\n"))),
      file_name
    ),
    ...
  )

  cli::cli_alert_success("Uploaded reprex to {.url {gist_info$html_url}}")

  return(invisible(gist_info$html_url))
}
