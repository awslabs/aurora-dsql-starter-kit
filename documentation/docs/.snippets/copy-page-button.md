<div style="text-align: right; margin-bottom: 20px;">
  <button onclick="copyPageContent()" style="background: #1976d2; color: white; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">
    📋 Copy Page
  </button>
</div>

<script>
function copyPageContent() {
  const content = document.querySelector('.md-content__inner');
  if (!content) {
    alert('Could not find page content');
    return;
  }
  
  // Get text content
  const text = content.innerText || content.textContent;
  
  // Copy to clipboard
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
    alert('Failed to copy: ' + err);
  });
}
</script>
