import app from "./app";

const PORT = parseInt(process.env.PORT || "4000", 10);

app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
