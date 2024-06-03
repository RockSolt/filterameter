# Filterameter Tests

The tests are written in RSpec and include both unit tests for the filterameter classes as well as a dummy application with models and controllers that support request specs.

## Test Application Data Model

The data model is primarily projects, activities, and tasks, with a few supporting models to enable association and multi-level association tests.

[![Data Model](https://yuml.me/diagram/scruffy;dir:LR/class/%5BProject%5D-%3E%5BActivity%5D,%20%5BActivity%5D-%3E%5BActivity%20Member%5D,%20%5BActivity%5D-%3E%5BTask%5D,%20%5BUser%5D-Activity%20Manager%3E%5BActivity%5D,%20%5BUser%5D-%3E%5BActivity%20Member%5D.svg)](https://yuml.me/diagram/scruffy;dir:LR/class/edit/%5BProject%5D-%3E%5BActivity%5D,%20%5BActivity%5D-%3E%5BActivity%20Member%5D,%20%5BActivity%5D-%3E%5BTask%5D,%20%5BUser%5D-Activity%20Manager%3E%5BActivity%5D,%20%5BUser%5D-%3E%5BActivity%20Member%5D)

In order to support testing across Rails versions, [the schema was manually edited to remove the Rails version in the `ActiveRecord::Schema.define` statement](https://github.com/RockSolt/filterameter/commit/742cfa91c30e640bff342740fb493176d9feb44e). If additional updates are made to the schema, this manual step will need to be repeated. (Versions prior to 7.1 do not add the stamp.)

## Request Specs

The request specs are broken up into the following groups:

- attribute filters
- scope filters
- partial filters
- range filters
- nested filters
- multi-level nested filters

The controllers use JSON repsonses because it is easier to check JSON responses than HTML responses.
