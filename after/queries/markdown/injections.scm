; extends

(
	fenced_code_block
	(info_string (language) @lang)
	(code_fence_content) @injection.content
	(#match? @lang "^\\.?(matplotlib|pyplt)$")
	(#set! injection.language "python")
)

(
	fenced_code_block
	(info_string (language) @lang)
	(code_fence_content) @injection.content
	(#match? @lang "^\\.?tikz$")
	(#set! injection.language "latex")
)
