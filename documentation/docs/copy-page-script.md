<script>
function copyPageContent(event) {
  const btn = event.target;
  const content = document.querySelector('.md-content__inner');
  if (!content) {
    alert('Could not find page content');
    return;
  }
  
  const text = content.innerText || content.textContent;
  
  // Try modern clipboard API first
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      const originalText = btn.innerHTML;
      btn.innerHTML = '✓ Copied!';
      btn.style.background = '#4caf50';
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.style.background = '#1976d2';
      }, 2000);
    }).catch(err => {
      // Fallback to old method
      fallbackCopy(text, btn);
    });
  } else {
    // Use fallback for older browsers
    fallbackCopy(text, btn);
  }
}

function fallbackCopy(text, btn) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-999999px';
  textArea.style.top = '0';
  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();
  
  try {
    const successful = document.execCommand('copy');
    if (successful) {
      const originalText = btn.innerHTML;
      btn.innerHTML = '✓ Copied!';
      btn.style.background = '#4caf50';
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.style.background = '#1976d2';
      }, 2000);
    } else {
      alert('Failed to copy content. Please copy manually.');
    }
  } catch (err) {
    alert('Failed to copy content. Please copy manually.');
  } finally {
    document.body.removeChild(textArea);
  }
}
</script>
