# Changelog

## [2.19.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.19.0...v2.19.1) (2026-02-17)


### Bug Fixes

* **folds:** prevent duplicate folds from stacking on repeated toggle ([3735409](https://github.com/jakewvincent/mkdnflow.nvim/commit/3735409448addce4f957df03680e90ce58905e8c)), closes [#162](https://github.com/jakewvincent/mkdnflow.nvim/issues/162)

## [2.19.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.18.0...v2.19.0) (2026-02-17)


### Features

* **cmp:** add footnote completion on [^ trigger ([c0f97d0](https://github.com/jakewvincent/mkdnflow.nvim/commit/c0f97d07d1832e2e4526b20d6e8e45d32d9c2950)), closes [#307](https://github.com/jakewvincent/mkdnflow.nvim/issues/307)
* **cmp:** add heading/anchor completions on ](# and [[# triggers ([eb335ef](https://github.com/jakewvincent/mkdnflow.nvim/commit/eb335ef73990bcbd6963f11e4cb414fa4da5e2fc)), closes [#307](https://github.com/jakewvincent/mkdnflow.nvim/issues/307)
* **cmp:** async file scanning and bib reading in completion source ([2bc3669](https://github.com/jakewvincent/mkdnflow.nvim/commit/2bc3669f46d4f734ddba2b5bd45f307bdd93680d)), closes [#307](https://github.com/jakewvincent/mkdnflow.nvim/issues/307)
* **cmp:** improve bib completion previews ([1443039](https://github.com/jakewvincent/mkdnflow.nvim/commit/144303905fe294ebf1545113611091d980818165)), closes [#307](https://github.com/jakewvincent/mkdnflow.nvim/issues/307)
* **cmp:** offer undefined footnote refs at line-start [^ trigger ([954fdcd](https://github.com/jakewvincent/mkdnflow.nvim/commit/954fdcd354b75eddbc74d7e552b12f324e1b83c7)), closes [#307](https://github.com/jakewvincent/mkdnflow.nvim/issues/307)

## [2.18.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.17.0...v2.18.0) (2026-02-15)


### Features

* **commands:** add :Mkdnflow subcommand dispatcher ([fdc7dfb](https://github.com/jakewvincent/mkdnflow.nvim/commit/fdc7dfb22abd9724815672ed579d82fea0f4d3e9)), closes [#233](https://github.com/jakewvincent/mkdnflow.nvim/issues/233)
* **links:** add per-call style override for link creation ([814a476](https://github.com/jakewvincent/mkdnflow.nvim/commit/814a4768d39efe414f165331e11494d63684cfa3)), closes [#264](https://github.com/jakewvincent/mkdnflow.nvim/issues/264)
* **links:** add transform_scope option for directory-aware link creation ([#223](https://github.com/jakewvincent/mkdnflow.nvim/issues/223)) ([9d63637](https://github.com/jakewvincent/mkdnflow.nvim/commit/9d63637de542b1125dd71c8e5e6c490e4309d386))
* **maps:** add on_attach callback and custom mappings docs ([#210](https://github.com/jakewvincent/mkdnflow.nvim/issues/210), [#232](https://github.com/jakewvincent/mkdnflow.nvim/issues/232)) ([47c98b2](https://github.com/jakewvincent/mkdnflow.nvim/commit/47c98b21a9f0420a7600b7139495ba6cb835b9ac))


### Bug Fixes

* **cmp:** use plugin path resolution for file completions ([2f84d79](https://github.com/jakewvincent/mkdnflow.nvim/commit/2f84d79f426f0762cd2385103db98b5802195eac)), closes [#197](https://github.com/jakewvincent/mkdnflow.nvim/issues/197)
* **demos:** set LetterSpacing 0 in tapes and update deprecated config ([f879485](https://github.com/jakewvincent/mkdnflow.nvim/commit/f87948514263b9728d0b139cb8d3856d8c70d5fa))

## [2.17.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.16.1...v2.17.0) (2026-02-15)


### Features

* **cursor:** yank file anchor links relative to resolution base ([5eef9da](https://github.com/jakewvincent/mkdnflow.nvim/commit/5eef9da276bd70562e7f1a7816347c272c67e06d)), closes [#201](https://github.com/jakewvincent/mkdnflow.nvim/issues/201)
* **links:** add custom URI scheme handlers ([7a96480](https://github.com/jakewvincent/mkdnflow.nvim/commit/7a96480a9956678ef30fa740741055965f877265)), closes [#167](https://github.com/jakewvincent/mkdnflow.nvim/issues/167)


### Bug Fixes

* **links:** join multi-line link names with spaces on destroy ([#85](https://github.com/jakewvincent/mkdnflow.nvim/issues/85)) ([7e3d004](https://github.com/jakewvincent/mkdnflow.nvim/commit/7e3d0040d3f0f780718809210f0810ff2a8a7a17))
* **links:** use correct config key for multi-line link detection ([#85](https://github.com/jakewvincent/mkdnflow.nvim/issues/85)) ([f93cafd](https://github.com/jakewvincent/mkdnflow.nvim/commit/f93cafd771a818744d33e615e1424e2b11c5cebb))

## [2.16.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.16.0...v2.16.1) (2026-02-14)


### Bug Fixes

* **cmp:** handle missing bib file in parse_bib ([fd1dc3a](https://github.com/jakewvincent/mkdnflow.nvim/commit/fd1dc3a7f50b67462ac08accc5da6c7a9ed3b52c)), closes [#203](https://github.com/jakewvincent/mkdnflow.nvim/issues/203)

## [2.16.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.15.0...v2.16.0) (2026-02-14)


### Features

* add config validation at setup time and in :checkhealth ([37a9cf6](https://github.com/jakewvincent/mkdnflow.nvim/commit/37a9cf6329b302a7879748bc562d22638b726637)), closes [#230](https://github.com/jakewvincent/mkdnflow.nvim/issues/230)
* **cursor:** use detection-based jumping for toNextLink/toPrevLink ([ba052f6](https://github.com/jakewvincent/mkdnflow.nvim/commit/ba052f64b8dd31a8d52b101ee9c9a2d4b9a06d28)), closes [#111](https://github.com/jakewvincent/mkdnflow.nvim/issues/111)
* **links:** add footnote renumbering and refresh commands ([f2aced0](https://github.com/jakewvincent/mkdnflow.nvim/commit/f2aced0635d0c5174fc0afaf9683418c4b786ef7)), closes [#111](https://github.com/jakewvincent/mkdnflow.nvim/issues/111)
* **links:** add virtual text hints for reference links ([13de530](https://github.com/jakewvincent/mkdnflow.nvim/commit/13de5300b1b7ecbfb79bae57f34620908686f6cc)), closes [#208](https://github.com/jakewvincent/mkdnflow.nvim/issues/208)
* **links:** smart footnote placement after word and trailing punctuation ([f1404fb](https://github.com/jakewvincent/mkdnflow.nvim/commit/f1404fbe71979fb70e9d2bfabaea5f9bbabe4e9a)), closes [#111](https://github.com/jakewvincent/mkdnflow.nvim/issues/111)
* **links:** support multi-line (setext) footnote headings ([c1c0603](https://github.com/jakewvincent/mkdnflow.nvim/commit/c1c06035871b44b6e95f7cd2aebd1ab118649311)), closes [#111](https://github.com/jakewvincent/mkdnflow.nvim/issues/111)
* **links:** support shortcut reference links, definition lines, and collapsed refs ([af2c215](https://github.com/jakewvincent/mkdnflow.nvim/commit/af2c215918e48bd051c230240e353b184f33d2c6)), closes [#208](https://github.com/jakewvincent/mkdnflow.nvim/issues/208)
* **links:** use &lt;cWORD&gt; for link creation to capture paths and punctuated text ([e8c5918](https://github.com/jakewvincent/mkdnflow.nvim/commit/e8c591868508157fb5524d9e80be7d08172e4ddf)), closes [#206](https://github.com/jakewvincent/mkdnflow.nvim/issues/206)
* **templates:** flatten placeholders config and add ctx fields ([e017177](https://github.com/jakewvincent/mkdnflow.nvim/commit/e017177e0cf73f01cda58144b5107e18fd801191)), closes [#300](https://github.com/jakewvincent/mkdnflow.nvim/issues/300) [#240](https://github.com/jakewvincent/mkdnflow.nvim/issues/240)
* **templates:** support function placeholders with context table ([a80c8d3](https://github.com/jakewvincent/mkdnflow.nvim/commit/a80c8d31e11cfab5cb5f6384a919330f022f6c55)), closes [#300](https://github.com/jakewvincent/mkdnflow.nvim/issues/300) [#240](https://github.com/jakewvincent/mkdnflow.nvim/issues/240)
* **to_do:** propagate parent status when new to-do item is added ([2a6c057](https://github.com/jakewvincent/mkdnflow.nvim/commit/2a6c057b7c2fe4bf3d1c36b32b2859c46a84bc34)), closes [#146](https://github.com/jakewvincent/mkdnflow.nvim/issues/146)


### Bug Fixes

* **docs:** preserve paragraph breaks in vimdoc config/command descriptions ([5096563](https://github.com/jakewvincent/mkdnflow.nvim/commit/5096563162da3abc56490fe405b9138802057727))

## [2.15.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.14.0...v2.15.0) (2026-02-13)


### Features

* **to_do:** convert plain text lines to to-do items with &lt;C-Space&gt; ([07546b8](https://github.com/jakewvincent/mkdnflow.nvim/commit/07546b8db20de5bbd5e1655750fcc1c0f6564b3b)), closes [#299](https://github.com/jakewvincent/mkdnflow.nvim/issues/299)


### Bug Fixes

* restore Neovim 0.9.5 compatibility for vim.keycode and vim.health ([bafc201](https://github.com/jakewvincent/mkdnflow.nvim/commit/bafc201ac96a7c4f17d3adb5842c376aa2dda312))

## [2.14.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.13.0...v2.14.0) (2026-02-13)


### Features

* **health:** add :checkhealth diagnostics and :MkdnCleanConfig command ([8bed591](https://github.com/jakewvincent/mkdnflow.nvim/commit/8bed59167ce0394b1e0ba9e451477ce5e89bbcf0))
* **health:** display MkdnCleanConfig in a floating window ([3ddb5af](https://github.com/jakewvincent/mkdnflow.nvim/commit/3ddb5af7d4983f9ae7423fb06598409e3f8e18fc))
* **lists:** add MkdnChangeListType command ([e9e71bc](https://github.com/jakewvincent/mkdnflow.nvim/commit/e9e71bc9af9106e6920693c2ec1724bbb70ff9d4)), closes [#216](https://github.com/jakewvincent/mkdnflow.nvim/issues/216)
* **lists:** add MkdnIndentListItem and MkdnDedentListItem commands ([a31727b](https://github.com/jakewvincent/mkdnflow.nvim/commit/a31727b2eeef74c4f68cbce36e5421c270d8b95c))
* **tables:** add MkdnTablePaste and MkdnTableFromSelection commands ([79b2b01](https://github.com/jakewvincent/mkdnflow.nvim/commit/79b2b01709f7471e9e3b4d5adbd99bc71df94546))
* **yaml:** accept `bibliography` as alias for `bib` in frontmatter ([d9caf3c](https://github.com/jakewvincent/mkdnflow.nvim/commit/d9caf3c670cf9f1b5f2ff9588b44e888a49982da))


### Bug Fixes

* **build:** make docs-verify compare file contents instead of git state ([b0dc478](https://github.com/jakewvincent/mkdnflow.nvim/commit/b0dc478b269ae3a6c05886b30ceb466efb379c19))
* **compat:** update_parents migration now merges instead of clobbering ([0130c0a](https://github.com/jakewvincent/mkdnflow.nvim/commit/0130c0ac9d8dcfc24b0d04d842c155569eff8b23))
* **links:** open non-notebook files with system viewer ([#188](https://github.com/jakewvincent/mkdnflow.nvim/issues/188)) ([08085a3](https://github.com/jakewvincent/mkdnflow.nvim/commit/08085a3a837c76916264b9e0dfe1f1cd5ae89d47))

## [2.13.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.12.0...v2.13.0) (2026-02-11)


### Features

* add getNotebook() API for statusline integration ([295e4a5](https://github.com/jakewvincent/mkdnflow.nvim/commit/295e4a5b12799f396dd506b09c5d4a19b57aeefb))
* **links:** visual selection on citation creates link instead of following ([759762e](https://github.com/jakewvincent/mkdnflow.nvim/commit/759762e75e0532fe18cb1e9bc569830af24006d7)), closes [#163](https://github.com/jakewvincent/mkdnflow.nvim/issues/163)
* **paths:** support nested collections with dynamic root re-evaluation ([268f538](https://github.com/jakewvincent/mkdnflow.nvim/commit/268f5381becc374413f156d3794115af2823bd13)), closes [#118](https://github.com/jakewvincent/mkdnflow.nvim/issues/118)


### Bug Fixes

* **links:** skip citation detection when @ is preceded by alphanumeric char ([237ab81](https://github.com/jakewvincent/mkdnflow.nvim/commit/237ab8167e0023419e6150cf94508c43f681c9f3))

## [2.12.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.11.0...v2.12.0) (2026-02-11)


### Features

* **demos:** add optional VARIANT arg to demos target ([907e00f](https://github.com/jakewvincent/mkdnflow.nvim/commit/907e00f6fb59f12ca9f7824adb37152b9776a2c8))


### Bug Fixes

* **demos:** update dark variant margin color to match GitHub dark mode ([48e5994](https://github.com/jakewvincent/mkdnflow.nvim/commit/48e5994469c89cdf8b3a778c93a92ebd705af428))

## [2.11.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.10.0...v2.11.0) (2026-02-11)


### Features

* **demos:** add VHS tape scripts and recording infrastructure ([a79413f](https://github.com/jakewvincent/mkdnflow.nvim/commit/a79413fe24babcaa253f63ddc7a3f46ab1b5d2d2))
* **to_do:** support converting plain list items via visual toggle ([870d8e2](https://github.com/jakewvincent/mkdnflow.nvim/commit/870d8e2e8849106f694cd793c90ea623012139f3))


### Bug Fixes

* **lists:** restore bidirectional sibling scan on promotion renumbering ([4bc0475](https://github.com/jakewvincent/mkdnflow.nvim/commit/4bc0475dedb9007cb0aeb1f7be1cc2a7bcbe6987))
* **to_do:** restore visual mode multi-line toggle via &lt;C-Space&gt; ([0a82739](https://github.com/jakewvincent/mkdnflow.nvim/commit/0a82739f69876417249b625fffb567914b25e4f2))
* **to_do:** skip children in visual range toggle when parent is selected ([d2b6ea0](https://github.com/jakewvincent/mkdnflow.nvim/commit/d2b6ea0dbae28d785d9c909a18bbce841d2ea8c6))
* **to_do:** support all visual modes in direct-call toggle path ([a5e4887](https://github.com/jakewvincent/mkdnflow.nvim/commit/a5e48878d6ff4bd562e92ff627853df87eeda697))

## [2.10.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.9.4...v2.10.0) (2026-02-09)


### Features

* **links:** add on_create_new callback for delegating file creation ([3cace55](https://github.com/jakewvincent/mkdnflow.nvim/commit/3cace55fc083d8cde5ad11cfc158a8f62a34c597)), closes [#261](https://github.com/jakewvincent/mkdnflow.nvim/issues/261)

## [2.9.4](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.9.3...v2.9.4) (2026-02-09)


### Bug Fixes

* **paths:** use correct config key for new file template injection ([b115777](https://github.com/jakewvincent/mkdnflow.nvim/commit/b115777f80b143f7d2bd35902aaf9f7c6c18d53a))

## [2.9.3](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.9.2...v2.9.3) (2026-02-09)


### Bug Fixes

* **tables:** fix Tab navigation on continuation lines and reuse empty cells on S-CR ([bbafb96](https://github.com/jakewvincent/mkdnflow.nvim/commit/bbafb96b19964edb9ecd8425a60ecac5cfb4f88d))

## [2.9.2](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.9.1...v2.9.2) (2026-02-09)


### Bug Fixes

* **paths:** resolve nil initial_dir when plugin loaded via keymap ([#293](https://github.com/jakewvincent/mkdnflow.nvim/issues/293)) ([0b7a668](https://github.com/jakewvincent/mkdnflow.nvim/commit/0b7a668046f2496e4d3573d6a8e96f3c2a68a000))

## [2.9.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.9.0...v2.9.1) (2026-02-09)


### Bug Fixes

* **to_do:** restore list item to to-do conversion on toggle ([#292](https://github.com/jakewvincent/mkdnflow.nvim/issues/292)) ([361b476](https://github.com/jakewvincent/mkdnflow.nvim/commit/361b476102d0aa34397f861ab7c5cf47f697961e))

## [2.9.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.8.1...v2.9.0) (2026-02-07)


### Features

* **tables:** add column alignment commands ([b052e28](https://github.com/jakewvincent/mkdnflow.nvim/commit/b052e287c82c66ca6a2fde9047c1fbe5698c146d))
* **tables:** add MkdnTableAlignDefault command to remove alignment ([29fcb86](https://github.com/jakewvincent/mkdnflow.nvim/commit/29fcb86199ec0d7be8c8ee8865e165578f27be9f))
* **tables:** add MkdnTableCellNewLine command for in-cell line breaks ([390f937](https://github.com/jakewvincent/mkdnflow.nvim/commit/390f937e990e5613c36f10b261820d766ac1fbad))
* **tables:** add Pandoc grid table support ([78045ca](https://github.com/jakewvincent/mkdnflow.nvim/commit/78045caae3199ea469fc07c0ad01ee565a3e185a)), closes [#278](https://github.com/jakewvincent/mkdnflow.nvim/issues/278)


### Bug Fixes

* **tables:** remove pipe-table multiline cell support ([b7b5917](https://github.com/jakewvincent/mkdnflow.nvim/commit/b7b59178dd0da5709d8db1542279ce96a1a677ae))

## [2.8.1](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.8.0...v2.8.1) (2026-02-05)


### Bug Fixes

* **ci:** install pyyaml for docs generation ([bbe640f](https://github.com/jakewvincent/mkdnflow.nvim/commit/bbe640f0b036298299c026ca392e1002c9d080a2))

## [2.8.0](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.7.2...v2.8.0) (2026-02-04)


### Features

* **links:** add support for Pandoc-style bracketed citations ([ec99c43](https://github.com/jakewvincent/mkdnflow.nvim/commit/ec99c433d527d024c3abd112f57dcb850f85a947)), closes [#285](https://github.com/jakewvincent/mkdnflow.nvim/issues/285)


### Bug Fixes

* **docs:** remove duplicate help tag in vimdoc ([3c9236c](https://github.com/jakewvincent/mkdnflow.nvim/commit/3c9236cbe2a5b8ec815edf6cf713b69fb8ced88e)), closes [#288](https://github.com/jakewvincent/mkdnflow.nvim/issues/288)

## [2.7.2](https://github.com/jakewvincent/mkdnflow.nvim/compare/v2.7.1...v2.7.2) (2026-02-04)


### Bug Fixes

* **foldtext:** use autocmd for buffer-local foldtext setting ([8a87f12](https://github.com/jakewvincent/mkdnflow.nvim/commit/8a87f12e83699c2f7b388558cade025192c650eb))
* **foldtext:** use global wrapper for v:lua compatibility ([6a64127](https://github.com/jakewvincent/mkdnflow.nvim/commit/6a64127696ebfeb2e9e88a2c74c548a01cdb5e12))
* **tests:** ignore highlight attrs in screenshot tests ([90fd255](https://github.com/jakewvincent/mkdnflow.nvim/commit/90fd255aa0ee665afd05496b13d163e7568a9f8d))

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
