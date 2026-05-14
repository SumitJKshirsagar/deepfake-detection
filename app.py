import os
import uuid
from flask import Flask, render_template, request, jsonify
from detector import analyze

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = os.path.join(os.path.dirname(__file__), "static", "uploads")
app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024  # 10 MB limit

os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "gif"}


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/analyze", methods=["POST"])
def analyze_image():
    try:
        # Handle file upload
        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            if not allowed_file(file.filename):
                return jsonify({"error": "Unsupported file type. Use JPG, PNG, or WebP."}), 400

            ext = file.filename.rsplit(".", 1)[1].lower()
            filename = f"{uuid.uuid4().hex}.{ext}"
            filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
            file.save(filepath)
            result = analyze(image_path=filepath)
            result["image_url"] = f"/static/uploads/{filename}"

        # Handle URL input
        elif request.form.get("url"):
            url = request.form["url"].strip()
            result = analyze(image_url=url)
            result["image_url"] = url

        else:
            return jsonify({"error": "Please upload an image or provide a URL."}), 400

        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True, port=5000)
