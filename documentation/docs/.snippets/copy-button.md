<button onclick="copyPageContent()" style="position: fixed; bottom: 20px; right: 20px; z-index: 1000; background: #1976d2; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
  📋 Copy Page
</button>

<script>
function copyPageContent() {
  const content = document.querySelector('.md-content__inner');
  if (content) {
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = content.innerHTML;
    const elementsToRemove = tempDiv.querySelectorAll('.md-source, .md-nav, .md-sidebar, .md-header, .md-footer, .md-content__button, button');
    elementsToRemove.forEach(el => el.remove());
    const text = tempDiv.innerText || tempDiv.textContent;
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.target;
      const originalText = btn.innerHTML;
      btn.innerHTML = '✓ Copied!';
      btn.style.background = '#4caf50';
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.style.background = '#1976d2';
      }, 2000);
    }).catch(err => {
      alert('Failed to copy content');
    });
  }
}
</script>
