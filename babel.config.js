module.exports = (api) => {
  api.cache(true);
  return {
    presets: [['@babel/preset-env', { modules: false, useBuiltIns: 'entry', corejs: 3 }]],
    plugins: [
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-proposal-private-methods', { loose: true }],
      ['@babel/plugin-proposal-private-property-in-object', { loose: true }]
    ]
  };
};
