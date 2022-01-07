const express = require('express')
const app = express()

app.listen(3000, '0.0.0.0', () => {
    console.log('Application is running at 0.0.0.0:3000')
})

app.get('/', (req,res) => {
    res.send('Sample API ')
})