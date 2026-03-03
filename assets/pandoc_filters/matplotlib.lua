local system = pandoc.system

local extension_for = {
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

local matplotlib_wrapper_template = [[
import sys, matplotlib
import matplotlib.pyplot as plt

_out, _dpi, _fmt = sys.argv[1], int(sys.argv[2]), sys.argv[3]
def _patched_show(*a, **kw):
    plt.savefig(_out, dpi=_dpi, format=_fmt, bbox_inches='tight')
plt.show = _patched_show

%s
]]

local function matplotlib2image(python_env, src_code, filetype, fname, dpi)
  system.with_temporary_directory('matplotlib', function(tmpdir)
    local script = tmpdir .. '/plot.py'
    local f, err = io.open(script, 'w')
    if not f then
      error('Could not open ' .. script .. ' for writing: ' .. (err or 'unknown error'))
    end
    f:write(matplotlib_wrapper_template:format(src_code))
    f:close()

    local cmd = string.format('%s %s %s %s %s ', python_env, script, fname, dpi, filetype)
    local ok, _, rc = os.execute(cmd)
    if not ok then
      warn('matplotlib.lua: python exited with code ' .. (rc or '?'))
    end
  end)
end

function CodeBlock(block)
  if not block.classes:includes 'matplotlib' then
    return nil
  end

  local caption_str = block.attributes['caption']
  local caption = caption_str and pandoc.read(caption_str).blocks or nil
  local alt = caption and pandoc.utils.blocks_to_inlines(caption) or {}

  local width = block.attributes['width'] or ''
  local dpi = block.attributes['dpi'] or '150'
  local fig_attr = { id = block.identifier }

  local python_env = os.getenv 'PYTHON_ENV' or 'python3'
  local filetype = extension_for[FORMAT] or 'svg'
  local code = block.text

  local cache_dir = os.getenv 'HOME' .. '/.cache/pandoc/'
  os.execute('mkdir -p ' .. cache_dir)
  local hash = pandoc.sha1(code .. '|' .. dpi .. '|' .. filetype)
  local fname = cache_dir .. hash .. '.' .. filetype

  if not file_exists(fname) then
    matplotlib2image(python_env, code, filetype, fname, dpi)
  end

  local img = pandoc.Image(alt, fname, '', { width = width })
  local fig = pandoc.Figure(pandoc.Plain { img }, caption, fig_attr)
  if FORMAT:match 'html' then
    img.attributes.style = 'margin:auto; display:block;'
    fig.attributes.style = 'text-align:center; margin:auto;'
  end
  return caption and fig
    or pandoc.Plain {
      pandoc.RawInline('latex', '\\begin{center}'),
      img,
      pandoc.RawInline('latex', '\\end{center}'),
    }
end
