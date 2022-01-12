local status_ok, vnotify = pcall(require, "notify")
if not status_ok then
  return
end

vim.notify = vnotify

