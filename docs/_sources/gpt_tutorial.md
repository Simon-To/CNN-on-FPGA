Below is a step-by-step guide on how you can use **Jupyter Book** to incorporate your existing code and Markdown files into a polished, notebook-like documentation site. We’ll assume you already have a repository containing some code in (for example) a `src/` folder, plus a few Markdown documents that you want to present in a cohesive way.

---

## 1. Install Jupyter Book

First, ensure you have Python 3.x installed. Then install Jupyter Book (preferably in a virtual environment) using:

```bash
pip install -U jupyter-book
```

---

## 2. Create the Jupyter Book Structure

Inside your project (or elsewhere, and then you can move it over), run:

```bash
jupyter-book create mybook
```

This command creates a starter folder, `mybook/`, with a basic structure:

```
mybook/
├── _config.yml
├── _toc.yml
├── intro.md
└── references.bib
```

- **`_config.yml`**: Global configuration for your book (title, authors, logo, theme, etc.).  
- **`_toc.yml`**: Table of Contents configuration. Defines the order and hierarchy of chapters/pages in your book.  
- **`intro.md`**: An example “home page” for your book.  

You can rename `mybook` to something like `docs` if you want it to live directly in your repo. For example:

```
my-repo/
├─ src/
│   ├─ ...
├─ tests/
│   ├─ ...
├─ docs/            # your Jupyter Book folder
│   ├─ _config.yml
│   ├─ _toc.yml
│   ├─ intro.md
│   └─ ...
└─ README.md
```

---

## 3. Add Your Existing Markdown Files

If you already have Markdown files you want to include, move or copy them into the `mybook/` (or `docs/`) folder. For example:

```
docs/
├─ _config.yml
├─ _toc.yml
├─ intro.md
├─ tutorial.md
├─ advanced.md
└─ ...
```

You can also add **Jupyter Notebooks** (`.ipynb`) if you have them. Jupyter Book can handle both Markdown files and notebooks in the same build.

---

## 4. Configure the Table of Contents

Open `_toc.yml` in your `docs/` folder to outline how readers will navigate your content. For example:

```yaml
# _toc.yml
format: jb-book
root: intro

chapters:
  - file: tutorial
  - file: advanced
```

- `root: intro` means `intro.md` is the homepage.
- Each `- file: tutorial` line references a Markdown (or Notebook) file in the same directory (without the `.md` extension in the TOC).
- You can nest items (sub-chapters) under `sections:` if you want a deeper hierarchy.

For more complex structures, see [Jupyter Book TOC documentation](https://jupyterbook.org/en/stable/structure/toc.html).

---

## 5. Reference Your Code

If you keep your code in `src/`, you can link to it from the Markdown pages. For example, in `tutorial.md`:

```markdown
# Tutorial

In this section, we'll show how to use the main function in [main.py](../src/main.py).

```  

- Relative paths are often easiest for linking to code in the same repository.  
- If you need to embed code snippets directly in your doc, just use fenced code blocks:

  ```markdown
  ```python
  # docs/tutorial.md
  from my_module import do_stuff

  do_stuff()
  ```
  ```

Additionally, Jupyter Book supports code cell blocks that can be executed and displayed if you convert your `.md` to [MyST Markdown](https://myst-parser.readthedocs.io/), but that’s optional.

---

## 6. Build & Preview Locally

From within the `docs/` folder (or wherever you placed your Jupyter Book), run:

```bash
jupyter-book build .
```

You should see a `_build/` directory appear, containing the HTML output. To preview locally, you can open `_build/html/index.html` in your browser or run a local server:

```bash
python -m http.server --directory _build/html 8000
```

Then visit `http://localhost:8000/`.

---

## 7. Publish on GitHub Pages

1. **Create a separate branch** (e.g., `gh-pages`) or use a `docs/` folder approach on your default branch to serve the site via GitHub Pages.  
2. In your repository’s **Settings** -> **Pages**, choose the source branch/folder.  
3. Push the built files from `_build/html/` to that branch/folder.  

### Automated Workflow with GitHub Actions

You can automate the build-and-deploy process using GitHub Actions. For instance, create a `.github/workflows/jupyterbook.yml` file in your repo:

```yaml
name: Build and deploy Jupyter Book

on:
  push:
    branches:
      - main  # or any branch you want to build from

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.x

      - name: Install dependencies
        run: |
          pip install -U jupyter-book

      - name: Build the book
        run: |
          cd docs
          jupyter-book build .

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: docs/_build/html
```

- This workflow checks out your code, installs Jupyter Book, builds the HTML in `docs/_build/html`, and deploys it to GitHub Pages automatically whenever you push to `main`.  
- Make sure your **GitHub Pages** settings point to the correct branch (`gh-pages`) or the `/docs` folder on `main`.  

---

## 8. Enhance Your Book

### 8.1. Customize `_config.yml`

You can personalize your book’s appearance and behavior:

```yaml
# _config.yml
title: "My Awesome Project"
author: "Your Name"
logo: images/my_logo.png
execute:
  execute_notebooks: off
html:
  favicon: images/favicon.ico
  theme:
    name: "sphinx_book_theme"
```

Check out [Configuration options](https://jupyterbook.org/en/stable/customize/config.html) for more details.

### 8.2. Add Interactive Code Cells

If you want your readers to **run code directly in their browsers** (e.g., with a Binder or Deepnote badge), you can add a “launch button.” For instance, at the top of your pages, include:

```yaml
launch_buttons:
  binderhub_url: https://mybinder.org
```

Then readers can click a button to open your notebooks (or repository) in an interactive environment.

---

## 9. Final Repository Structure Example

Here’s how it might look once you integrate Jupyter Book into your existing project:

```
my-repo/
├─ src/                  
│   ├─ main.py           
│   └─ ...
├─ tests/                
│   ├─ ...
├─ docs/                 # Jupyter Book
│   ├─ _config.yml
│   ├─ _toc.yml
│   ├─ intro.md
│   ├─ tutorial.md
│   ├─ advanced.md
│   └─ images/
├─ README.md             # Summary / instructions
└─ .github/workflows/    # GitHub Actions for CI/CD
   └─ jupyterbook.yml
```

- **`src/`**: All your project code.  
- **`docs/`**: Jupyter Book source, with Markdown (and/or notebooks).  
- **`README.md`**: Quick project overview (often referencing your docs site).  
- **`.github/workflows/`**: Automated build/deployment to GitHub Pages or other environment.

---

## Key Takeaways

1. **Jupyter Book** transforms Markdown (and notebook) files into a cohesive, book-style website.  
2. **Keep your code** in a separate folder (e.g., `src/`), and link to relevant files from your docs.  
3. **_toc.yml** and **_config.yml** let you customize the structure and theme of your book.  
4. **Use GitHub Actions** to automate builds and deploy to GitHub Pages for seamless hosting.  

With this setup, you’ll have a neat “documentation hub” for all your Markdown files—presented as a professionally styled, interactive book—while still keeping your source code organized in its own part of the repository. Readers (and contributors) can easily browse your code, read your tutorials, view interactive notebooks, and enjoy a consistent look and feel.