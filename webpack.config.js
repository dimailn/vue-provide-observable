var path = require('path');

module.exports = {
  entry: './lib/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'index.js',
    libraryTarget: 'umd',
    libraryExport: 'default',
    library: 'vpo',
    publicPath: '/dist/',
    globalObject: `typeof self !== 'undefined' ? self : this`
  },
  externals: {
    vue: {
      commonjs: 'vue',
      commonjs2: 'vue',
      amd: 'vue',
      root: 'Vue',
    },
  },
  mode: 'production'
};