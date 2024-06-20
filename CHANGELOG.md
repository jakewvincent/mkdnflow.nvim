# Changelog

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
