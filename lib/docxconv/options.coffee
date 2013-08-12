# Default options for Tidy
tidyOpts = {
  altText: '',
  bare: false, # Keep smart quotes, etc.
  breakAfterBr: false,
  charEndcoding: 'utf8',
  clean: true,
  decorateInferredUl: true,
  doctype: 'html5',
  dropEmptyParas: true,
  dropFontTags: true,
  dropProprietaryAttributes: true,
  forceOutput: true,
  hideComments: false,
  indent: true,
  outputEncoding: 'utf8',
  outputHtml: true,
  showBodyOnly: true
  tabSize: 2,
  tidyMark: false,
  verticalSpace: false,
  wrap: 80,
}

exports.tidy = tidyOpts
