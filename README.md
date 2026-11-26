# Kotlin AI Backend API

## Endpoints

1. **Check Server Status**
   `GET /`

2. **Generate New API Key**
   `GET /generate-key?name=YourName`
   Example: `https://your-app.onrender.com/generate-key?name=Amit`

3. **Ask a Question**
   `GET /ask?key=YOUR_API_KEY&q=YOUR_QUESTION`
   Example: `https://your-app.onrender.com/ask?key=sk-demo-99999&q=kotlin kya hai`
