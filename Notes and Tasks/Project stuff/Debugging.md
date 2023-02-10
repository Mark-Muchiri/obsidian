# Things to change
### `SignupCard.js`
- [ ] Change the nesting object data in `const [formData, setFormData] = useState ...` and change it to simple data entry format
- [ ] Change the object data in `const { ... } = formData` to simple data
- [ ] Change the names in the html code below.
- [ ] Checkout this ( 👇 ) express code and see how it's stopping the code from posting data to the database. Also check the error that it causes in the browser `console >_`
```js
/**
 * Express set ups
 */
let cors = require("cors");
const express = require("express");
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
```

