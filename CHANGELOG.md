# Changelog

## [2.7.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.7.0...v2.7.1) (2026-02-04)


### Bug Fixes

* **maps:** enable dot-repeat for +/- in visual mode ([41a636d](https://github.com/jakewvincent/mkdnflow.nvim/commit/41a636dda479b9df03bf4c717c0c5e7d9f900dd4))
* **maps:** use feedkeys fallback instead of expr mappings ([9c084a9](https://github.com/jakewvincent/mkdnflow.nvim/commit/9c084a9b89df2839221941a4401d4022530b6f83))
* **test:** mock clipboard for CI environments ([d6d9a37](https://github.com/jakewvincent/mkdnflow.nvim/commit/d6d9a3710dd90d256bfac732b8eceaa666d3a308))

## [2.7.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.6.0...v2.7.0) (2026-02-03)


### Features

* **tables:** add row and column deletion commands ([a913d5b](https://github.com/jakewvincent/mkdnflow.nvim/commit/a913d5b89a0978ae3d9e454633732f5f12e61394))

## [2.6.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.5.0...v2.6.0) (2026-02-03)


### Features

* **tables:** add inline line break splitting during format ([0762f91](https://github.com/jakewvincent/mkdnflow.nvim/commit/0762f9126a378b495fae57f2c25460cf270d1451)), closes [#243](https://github.com/jakewvincent/mkdnflow.nvim/issues/243)
* **tables:** add multiline row support with backslash continuation ([6d93dc3](https://github.com/jakewvincent/mkdnflow.nvim/commit/6d93dc3d5d7c734011e3de5f152e17a9d45c1f07)), closes [#243](https://github.com/jakewvincent/mkdnflow.nvim/issues/243)


### Bug Fixes

* **lists:** respect expandtab and shiftwidth for list indentation ([a2c2c2d](https://github.com/jakewvincent/mkdnflow.nvim/commit/a2c2c2d4d7db1a24b75cf9ad9b105758e7ac841b)), closes [#267](https://github.com/jakewvincent/mkdnflow.nvim/issues/267)
* **tables:** correct multiline cell width calculation and navigation ([5dc2cb2](https://github.com/jakewvincent/mkdnflow.nvim/commit/5dc2cb2fd2597a7c362c61c0781ed65e484b0934))
* **tables:** position cursor on cell content, not padding ([313e333](https://github.com/jakewvincent/mkdnflow.nvim/commit/313e3333ec1faffc2de27bf8ba9e0d23eaa12da0))

## [2.5.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.4.0...v2.5.0) (2026-02-02)


### Features

* **cursor:** add range support and dot-repeatable heading operators ([#256](https://github.com/jakewvincent/mkdnflow.nvim/issues/256)) ([da5dac1](https://github.com/jakewvincent/mkdnflow.nvim/commit/da5dac1ee1a153139c73fc6ce230b7d8d2bc0671))


### Bug Fixes

* **config:** replace array-like tables instead of merging ([#268](https://github.com/jakewvincent/mkdnflow.nvim/issues/268)) ([408185c](https://github.com/jakewvincent/mkdnflow.nvim/commit/408185ca02fa59f493f6556a47fc870a25c7b18a))

## [2.4.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.3.0...v2.4.0) (2026-02-02)


### Features

* **cursor:** add configurable yank register ([#224](https://github.com/jakewvincent/mkdnflow.nvim/issues/224)) ([62930a3](https://github.com/jakewvincent/mkdnflow.nvim/commit/62930a3200ac347881c62ce42353dbbcd5ee296b))
* **maps:** add descriptions to keymaps for which-key ([#259](https://github.com/jakewvincent/mkdnflow.nvim/issues/259)) ([a147b26](https://github.com/jakewvincent/mkdnflow.nvim/commit/a147b26d90ed9dc185bb0efdb971d6a15bf7b567))

## [2.3.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.2.1...v2.3.0) (2026-02-02)


### Features

* **to_do:** add MkdnSortToDoList command ([#209](https://github.com/jakewvincent/mkdnflow.nvim/issues/209)) ([cc190dd](https://github.com/jakewvincent/mkdnflow.nvim/commit/cc190ddb18e965c0075e6978d9f84d0c25ed1674))

## [2.2.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.2.0...v2.2.1) (2026-02-01)


### Bug Fixes

* **tests:** add mock clipboard for headless CI environments ([3c95720](https://github.com/jakewvincent/mkdnflow.nvim/commit/3c95720180fefe1182caf2ecc20a4e3d41319b22))

## [2.2.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.1.1...v2.2.0) (2026-02-01)


### Features

* **links:** add image link support ([#220](https://github.com/jakewvincent/mkdnflow.nvim/issues/220)) ([3d17309](https://github.com/jakewvincent/mkdnflow.nvim/commit/3d17309ab65767fc5122fb37cad51975b8a1d2bf))
* **links:** add Unicode anchor link support ([#221](https://github.com/jakewvincent/mkdnflow.nvim/issues/221)) ([b69011d](https://github.com/jakewvincent/mkdnflow.nvim/commit/b69011d094e2e59aab4e905aba52a962d7c4c0e7))


### Bug Fixes

* **folds:** handle non-manual foldmethod gracefully ([#254](https://github.com/jakewvincent/mkdnflow.nvim/issues/254)) ([191b6df](https://github.com/jakewvincent/mkdnflow.nvim/commit/191b6df17746a0cfeca7e6db8c1ee72e52fae953))

## [2.1.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.1.0...v2.1.1) (2026-02-01)


### Bug Fixes

* **links:** prevent crash when following link in task list ([#269](https://github.com/jakewvincent/mkdnflow.nvim/issues/269)) ([04e138b](https://github.com/jakewvincent/mkdnflow.nvim/commit/04e138b35ecb59e7d9130b18f0ec3bbaed1fc5e7))
* **links:** use non-greedy patterns for link part extraction ([#252](https://github.com/jakewvincent/mkdnflow.nvim/issues/252)) ([552998e](https://github.com/jakewvincent/mkdnflow.nvim/commit/552998e52a9e089eb4fd9d31d3e5c6ef265743f8))
* **links:** use visual selection marks when range=true ([#258](https://github.com/jakewvincent/mkdnflow.nvim/issues/258)) ([80d5c30](https://github.com/jakewvincent/mkdnflow.nvim/commit/80d5c30cedd07a4e390dabe1c45d4096a99d757d))
* **plugin:** prevent crash when commands called before setup ([#255](https://github.com/jakewvincent/mkdnflow.nvim/issues/255)) ([36af02d](https://github.com/jakewvincent/mkdnflow.nvim/commit/36af02d2dbace62846fe5c9a004d5a36710177b0))
* **tables:** preserve escaped pipes when adding columns ([#244](https://github.com/jakewvincent/mkdnflow.nvim/issues/244)) ([90b10fc](https://github.com/jakewvincent/mkdnflow.nvim/commit/90b10fc4827c23b56671caf49470d6480bcc35e4))

## [2.1.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.0.0...v2.1.0) (2026-01-31)


### Features

* only trigger suggestions for bib if @ is typed ([c82ce65](https://github.com/jakewvincent/mkdnflow.nvim/commit/c82ce65bf20c0d0e982d1224f62a5ce609069645))
* only trigger suggestions for bib if @ is typed ([5f32b78](https://github.com/jakewvincent/mkdnflow.nvim/commit/5f32b7852b20b8b024abc53e02989362d895c0e8))


### Bug Fixes

* Also trigger bib completions at start of line ([c70a8b8](https://github.com/jakewvincent/mkdnflow.nvim/commit/c70a8b88668e43316036efb397c724509940adac))
* **bib:** return nil for empty citation key ([cfab8ac](https://github.com/jakewvincent/mkdnflow.nvim/commit/cfab8acf58588d2fd3e5adc2dd5a04ba4b74f549))
* **paths:** handle nil replacement in formatTemplate ([3f19ec7](https://github.com/jakewvincent/mkdnflow.nvim/commit/3f19ec74910b9e589e622a3a7f6e88ed3093b685))
* **yaml:** fix crashes and colon parsing in YAML frontmatter ([d2bad25](https://github.com/jakewvincent/mkdnflow.nvim/commit/d2bad25c4fe01d419cb8e487cd9aaada0d9c4854))

## [2.0.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.2.4...v2.0.0) (2026-01-31)


### ⚠ BREAKING CHANGES

* The `symbol` and `colors` keys in to_do.statuses configuration have been renamed to `marker` and `highlight`. The old keys are deprecated and will be removed in a future major version.

### Features

* Add backwards compatibility for deprecated to_do config keys ([46ca5bc](https://github.com/jakewvincent/mkdnflow.nvim/commit/46ca5bcc2a4840fd49631262a53b2ad19b64bfd9))
* Add to-do item caching to improve performance ([9aae1ca](https://github.com/jakewvincent/mkdnflow.nvim/commit/9aae1ca4abfa89403b6737c1ba230077ce5330bd))
* Add Version information section and improve README generator script ([596f9a2](https://github.com/jakewvincent/mkdnflow.nvim/commit/596f9a2855d3f4489e5e23736afec2cd49d1d444))


### Bug Fixes

* Add deprecation warning and guard for individual keys migration ([353e90f](https://github.com/jakewvincent/mkdnflow.nvim/commit/353e90f7c20f06f034039e297a87d3aa678ae8a3))
* Add deprecation warning for update_parents config key ([ca8946e](https://github.com/jakewvincent/mkdnflow.nvim/commit/ca8946ed4438ff5c47b6898b410d563d2fcbe4a8))
* Address off-by-one cursor position error with blank markers ([7d67410](https://github.com/jakewvincent/mkdnflow.nvim/commit/7d6741053a62cbbc57daaf532f9779dc2a6e2bfc))
* Handle edge cases in table navigation ([250e562](https://github.com/jakewvincent/mkdnflow.nvim/commit/250e562f367dab3518e55769ff07852e5719cd52))
* Handle non-to-do lines gracefully in to-do functions ([fcbf8cb](https://github.com/jakewvincent/mkdnflow.nvim/commit/fcbf8cb0eb7b54eb62ead65551aa5efb196421ea))
* Improve cursor positioning during to-do list sorting ([5c305bf](https://github.com/jakewvincent/mkdnflow.nvim/commit/5c305bfa47006d801485cd09a7d4d860a415408f))
* Treat incomplete tables as normal text for navigation ([ff1b0bb](https://github.com/jakewvincent/mkdnflow.nvim/commit/ff1b0bb2e57838451b4975632782b61c49714ba0))
* Use vim.tbl_contains for Neovim 0.9.x compatibility ([2dae94e](https://github.com/jakewvincent/mkdnflow.nvim/commit/2dae94e6266c8653374de985f61dc2501d845260))

## [1.2.4](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.2.3...v1.2.4) (2024-08-25)


### Bug Fixes

* Check first line for bib entry too ([4638b05](https://github.com/jakewvincent/mkdnflow.nvim/commit/4638b05c8ad7a54cffea1767d1f36c939394489d))

## [1.2.3](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.2.2...v1.2.3) (2024-08-18)


### Bug Fixes

* Check for nil ([f04c36b](https://github.com/jakewvincent/mkdnflow.nvim/commit/f04c36b499630d7aee58ff7470e35792661baed8))
* Use native `shellescape` to escape characters ([2cc37ed](https://github.com/jakewvincent/mkdnflow.nvim/commit/2cc37edbc0d36ad0447ab9d62244c13b0a228dc5))

## [1.2.2](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.2.1...v1.2.2) (2024-07-29)


### Bug Fixes

* foldtext option changed locally instead of globally ([85747d3](https://github.com/jakewvincent/mkdnflow.nvim/commit/85747d3da3fc2c8c076ee4edf7bd04553d053758))

## [1.2.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.2.0...v1.2.1) (2024-07-10)


### Bug Fixes

* Prevent infinite loop by using custom gmatch iterator ([#237](https://github.com/jakewvincent/mkdnflow.nvim/issues/237)) ([e856877](https://github.com/jakewvincent/mkdnflow.nvim/commit/e85687784a5549c59f5f90f2d2c324a8ce7f8d8b))

## [1.2.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.1.2...v1.2.0) (2024-06-20)


### Features

* Add paragraph icons ([dfe30f8](https://github.com/jakewvincent/mkdnflow.nvim/commit/dfe30f8ca91a47bc3de13bec5e2ca46932b3740d))
* Add pattern for paragraph matching ([dcced74](https://github.com/jakewvincent/mkdnflow.nvim/commit/dcced74adbeec79933ae75fc89c552a1338bf0ad))
* Avoid errors if object count patterns are passed in as strings ([ac22e37](https://github.com/jakewvincent/mkdnflow.nvim/commit/ac22e37b78302fd945c5a90d2127533dd009164c))
* Count paragraphs; distinguish from empty lines ([ebd653e](https://github.com/jakewvincent/mkdnflow.nvim/commit/ebd653e08fa55b3b2265e163901157fa9e70fce1))
* Inject object count defaults into user table ([66f4ba6](https://github.com/jakewvincent/mkdnflow.nvim/commit/66f4ba6f4760529090c52e99f5534314b8bfa2f5))
* Only try to get value if there is a value ([1b0e415](https://github.com/jakewvincent/mkdnflow.nvim/commit/1b0e415841ca7c4d6c433ca0954afe289ec43048))
* Show line percentage and word count in foldtext ([a42ac35](https://github.com/jakewvincent/mkdnflow.nvim/commit/a42ac35eeba8731bf87ff152cd47d4d11002390f))


### Bug Fixes

* Add missing bracket in pattern ([def7c62](https://github.com/jakewvincent/mkdnflow.nvim/commit/def7c6215cb494c32ea667c989864455b6cbb8fa))
* Add missing pattern & fix tally method for to-do list items ([9b5209f](https://github.com/jakewvincent/mkdnflow.nvim/commit/9b5209f95e31695d2f1fdca20685e996e0fa24dd))
* Add missing space for (plural) line count ([fc2c2ce](https://github.com/jakewvincent/mkdnflow.nvim/commit/fc2c2ce63e04db06c67118a0270698e54ff0268e))
* Remove extra space after single-width chars ([3ee963c](https://github.com/jakewvincent/mkdnflow.nvim/commit/3ee963cf5ab38b78b3c2ffa6e66480dd92434a7c))
* Typo ([1902275](https://github.com/jakewvincent/mkdnflow.nvim/commit/1902275e56975960f9e2e865f576ca3d99aab750))
* Update example recipe to match screenshot example ([5aa3f66](https://github.com/jakewvincent/mkdnflow.nvim/commit/5aa3f66384e7b6182df99adbd48b42a5e554b19b))
* Update example recipe to match screenshot example (2nd attempt) ([ac719f6](https://github.com/jakewvincent/mkdnflow.nvim/commit/ac719f688de6f8307fc82eebe4d0672312f438f8))
* Use the merged layer when saving ([6e108d3](https://github.com/jakewvincent/mkdnflow.nvim/commit/6e108d33090f0069e4e89442bca492e3cf315c85))

## [1.1.2](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.1.1...v1.1.2) (2024-06-14)


### Bug Fixes

* Avoid re-folding; use existing folds ([ed3452a](https://github.com/jakewvincent/mkdnflow.nvim/commit/ed3452a8c1b2f724b82dc6138a0fd71a8fc0683a))

## [1.1.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.1.0...v1.1.1) (2024-06-05)


### Bug Fixes

* Ignore heading under cursor in codeblock ([ad3b738](https://github.com/jakewvincent/mkdnflow.nvim/commit/ad3b73874c8c4b5f04d9c87b8303a0f776178344))
* Ignore section headings in md codeblocks ([05d5693](https://github.com/jakewvincent/mkdnflow.nvim/commit/05d569319241c7addcc5748c4800141dda18c559))

## [1.1.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v1.0.0...v1.1.0) (2024-06-04)


### Features

* Make link creation after failed follow optional ([b1cea92](https://github.com/jakewvincent/mkdnflow.nvim/commit/b1cea92882ea42e2c64219e8f5b6215f8e22306a))


### Bug Fixes

* Ignore heading patterns in fenced code blocks ([4864c6b](https://github.com/jakewvincent/mkdnflow.nvim/commit/4864c6ba1a6f8d4e20d0ac8370931c49c24c6625))
