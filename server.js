const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const webpush = require('web-push');

const app = express();
app.use(bodyParser.json());

const publicVapidKey = 'BNqwpw51oJUvhrUouq-PON5ZfLUJQ_ZpPdZnks5g4w4517HCQV9tDpAr39P4fUBgF7ZOohMBF0IoS7io2V5Cl7M';
const privateVapidKey = 'lGvoOsfLFFfMURGCD0WGJYwcYY1RKWyGtEZ9dZsWSeo';

webpush.setVapidDetails('meer.chehab@gmail.com', publicVapidKey, privateVapidKey);

app.post('/subscribe', (req, res) => {
    const subscription = req.body;
    res.status(201).json({});
    const payload = JSON.stringify({ title: 'Test Notification' });
    webpush.sendNotification(subscription, payload).catch(error => console.error(error));
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

app.listen(3000, () => console.log('Server started on port 3000'));
