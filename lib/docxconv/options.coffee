argv = require('optimist')
  .usage('Usage: $0 [-foc] <file>|<glob> ...')
  .alias('f', 'format')
  .default('f', 'html')
  .describe('f', 'conversion format')
  .alias('o', 'output')
  .demand('o')
  .describe('o', 'output destination')
  .alias('c', 'concurrency')
  .describe('c', 'queue concurrency')
  .default('c', 4)
  .argv

exports.argv = argv

tidyOpts = {
  bare: true,
  clean: true,
  doctype: 'html5',
  hideComments: false,
  wrap: 80,
  tabSize: 2,
  indent: true,
  altText: '',
  dropEmptyParas: true,
  dropFontTags: true,
  dropProprietaryAttributes: true,
  breakAfterBr: false,
  forceOutput: true,
  outputEncoding: 'utf-8',
  verticalSpace: true,
  tidyMark: false,
  showBodyOnly: true
}

exports.tidy = tidyOpts
