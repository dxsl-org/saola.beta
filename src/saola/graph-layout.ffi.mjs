let worker = null

export function request_layout(nodes, edges, callback) {
  if (typeof Worker === 'undefined') return

  if (!worker) {
    worker = new Worker(
      new URL('./graph_layout_worker.js', import.meta.url),
      { type: 'module' },
    )
  }

  const id = Math.random()
  const handler = (e) => {
    if (e.data.id !== id) return
    worker.removeEventListener('message', handler)
    callback(e.data.result)
  }
  worker.addEventListener('message', handler)
  worker.postMessage({ id, nodes, edges })
}
