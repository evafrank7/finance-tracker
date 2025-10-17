const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

// Provide jQuery/Popper for Bootstrap 4
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
)


module.exports = environment
