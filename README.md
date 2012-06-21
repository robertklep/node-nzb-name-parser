node-nzb-name-parser
====================

NZB filename parser for Node.

Usage
-----

```javascript
var parser = require('nzb-name-parser');
var result = parser(NZB_FILENAME);
if (result)
{
    // process result
}
else
{
    // failed
}
```

Disclaimer
----------

Partly based on [tvrenamr](https://github.com/ghickman/tvrenamr).
