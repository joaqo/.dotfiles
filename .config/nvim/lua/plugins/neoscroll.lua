-- There's probably better plugins out there, search for them if you get frustrated with this one.

return {
  {
    "karb94/neoscroll.nvim",
    config = function(lazy_plugin, opts)
        require('neoscroll').setup()
    end
  }
}
