local system = require 'pandoc.system'

local tikz_doc_template = [[
\documentclass{standalone}
\usepackage{xcolor}
\usepackage{tikz}
\usetikzlibrary{quantikz2}
\usetikzlibrary{shapes.arrows, shadows, optics}
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
  system.with_temporary_directory('tikz2image', function(tmpdir)
    system.with_working_directory(tmpdir, function()
      local f = io.open('tikz.tex', 'w')
      f:write(tikz_doc_template:format(subtype, src, subtype))
      f:close()
      os.execute 'pdflatex tikz.tex'
      if filetype == 'pdf' then
        os.rename('tikz.pdf', outfile)
      else
        os.execute('pdf2svg tikz.pdf ' .. outfile)
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
        -- pandoc.RawInline('latex', '\\hfill\\break{\\centering'),
        pandoc.RawInline('latex', '\\begin{center}'),
        para,
        pandoc.RawInline('latex', '\\end{center}'),
        -- pandoc.RawInline('latex', '\\par}'),
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
