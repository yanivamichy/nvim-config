local system = require 'pandoc.system'

local tikz_doc_template = [[
\documentclass{standalone}
\usepackage{xcolor}
\usepackage{tikz}
\usetikzlibrary{quantikz2}
\usetikzlibrary{shapes.arrows, shadows, optics, decorations}
\usetikzlibrary{calc}
\usepackage{pgfgantt}
\makeatletter
\tikzset{
  show_fig_name/.code={
    \tikz@addmode{
      \message{Fig name is: |\tikz@fig@name|}
    }
  }
}
\makeatother
\begin{document}
\nopagecolor
\begin{%s}
%s
\end{%s}
\end{document}
]]

local function tikz2image(src, filetype, outfile, subtype)
  local source_dir = (PANDOC_STATE.input_files[1] or '.'):match '(.*/)' or '.'
  system.with_working_directory(source_dir, function()
    system.with_temporary_directory('tikz2image', function(tmpdir)
      texfile = tmpdir .. '/tikz.tex'
      local f = io.open(texfile, 'w')
      f:write(tikz_doc_template:format(subtype, src, subtype))
      f:close()
      os.execute(string.format('pdflatex -output-directory=%s %s', tmpdir, texfile))

      local pdfout = tmpdir .. '/tikz.pdf'
      if filetype == 'pdf' then
        os.rename(pdfout, outfile)
      else
        os.execute('pdf2svg ' .. pdfout .. ' ' .. outfile)
      end
    end)
  end)
end

extension_for = {
  html = 'svg',
  html4 = 'svg',
  html5 = 'svg',
  latex = 'pdf',
  beamer = 'pdf',
}

local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function CodeBlock(block)
  if block.classes:includes 'tikz' then
    local subtype = block.attributes['subtype'] or 'tikzpicture'
    local caption = block.attributes['caption'] or {}
    local title = block.attributes['title'] or ''
    local align = block.attributes['align'] or ''
    local width = block.attributes['width'] or ''
    local filetype = extension_for[FORMAT] or 'svg'
    local fbasename = pandoc.sha1(block.text) .. '.' .. filetype
    local cache_dir = os.getenv 'HOME' .. '/.cache/pandoc/'
    os.execute('mkdir -p ' .. cache_dir)
    local fname = cache_dir .. fbasename

    if not file_exists(fname) then
      tikz2image(block.text, filetype, fname, subtype)
    end
    local para = pandoc.Image(caption, fname, title, { width = width })
    if FORMAT:match 'latex' then
      return pandoc.Para {
        pandoc.RawInline('latex', '\\begin{center}'),
        para,
        pandoc.RawInline('latex', '\\end{center}'),
      }
    end
    if FORMAT:match 'html' then
      para.attributes.style = 'margin:auto; display: block;'
      return para
    end
    return para
  else
    return block
  end
end
