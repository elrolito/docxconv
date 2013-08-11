# Default options for Tidy
tidyOpts = {
  altText: '',
  bare: true,
  breakAfterBr: false,
  clean: true,
  doctype: 'html5',
  dropEmptyParas: true,
  dropFontTags: true,
  dropProprietaryAttributes: true,
  forceOutput: true,
  hideComments: false,
  indent: true,
  outputEncoding: 'utf-8',
  showBodyOnly: true
  tabSize: 2,
  tidyMark: false,
  verticalSpace: true,
  wrap: 80,
}

exports.tidy = tidyOpts
