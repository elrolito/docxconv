opts = exports = module.exports = {}

# Default options for Tidy
opts.tidy = {
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
  inputEncoding: 'utf8',
  outputEncoding: 'utf8',
  outputHtml: true,
  showBodyOnly: true
  tabSize: 2,
  tidyMark: false,
  verticalSpace: false,
  wrap: 80,
}

opts.pandoc = [
  '-p',
  '-R',
  '-S',
  '--columns=80',
  '--normalize',
  '--old-dashes'
]
