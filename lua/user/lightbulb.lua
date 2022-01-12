local status_ok, lightbulb = pcall(require, "nvim-lightbulb")
if not status_ok then
  return
end

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

