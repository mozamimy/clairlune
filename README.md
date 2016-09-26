# Clairlune

Clairlune is a tool to package AWS Lambda function with npm modules for deployment.

## Overview

AWS Lambda is very useful but we have to build native npm modules in Amazon Linux environment when we want to use these modules.

Clairlune consits of a Lambda function (Node.js) and Ruby code.
The function is invoked to build npm modules, and upload it to S3 bucket.

Ruby code provides the interface to use the Lambda function.
So the building process can be integrated to Ruby program, Rake task, Rails application etc.

## Requirements

- AWS credential
- Ruby 2.3+

## Installation

1. Execute `$ npm install` in ./lambda/clairlune directory.
2. Zip ./lambda/clairlune directory and upload it to Lambda.

TODO: Create installer

## Usage

### Adapt your package.json to clairlune

A section `clairlune` is required like following sample code when use clairlune.

```json
{
  "name": "my-awesome-function",
  "private": true,
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "aws-sdk": "^2.6.0",
    "node-uuid": "^1.4.7",
    "@google-cloud/storage": "^0.1.1"
  },
  "engines": {
    "node": "4.3.2"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "mozamimy (Moza USANE) <mozamimy@quellencode.org>",
  "clairlune": {
    "bucket": "my-awesome-bucket",
    "key": "node_modules.zip"
  }
}
```

### In Ruby code

```ruby
require 'clairlune'

builder = Clairlune::Builder.new(
  bucket: 'my-awesome-bucket',
  key: 'node_modules.zip',
  package_json: '/path/to/package.json',
  function_name: 'clairlune',
  dest: '/path/to/node_modules.zip',
)
builder.performe
```

### As CLI tool

TODO: Not yet implemented CLI interface.

## Progress report

- [x] Lambda function to build npm modules
- [x] Core toolkit with Ruby
- [ ] Installer
- [ ] CLI interface
- [ ] Documentation

## License

MIT

## Contributing

1. Fork it ( https://github.com/mozamimy/clairlune/fork )
2. Create your feature branch (`git checkout -b awesome-feature`)
3. Commit your changes (`git commit -am 'Add an awesome feature'`)
4. Push to the branch (`git push origin awesome-feature`)
5. Create a new Pull Request
