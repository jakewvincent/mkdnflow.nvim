local M = require('mkdnflow.to_do.core')

if require('mkdnflow').config.to_do.highlight then
    require('mkdnflow.to_do.hl').highlight()
end

return M
