export const labels = { draft: '草稿', collecting: '征集中', preparing: '筹备中', on_view: '展出中', archived: '已归档', cancelled: '已取消' }
export const date = value => value ? value.slice(0, 16).replace('T', ' ') : '待公布'
export async function request(path, options = {}) {
  const response = await fetch(path, { ...options, headers: { 'Content-Type': 'application/json', 'X-Zhanxu-Request': '1', ...options.headers }, signal: AbortSignal.timeout(10000) })
  if (response.status === 204) return null
  const data = await response.json()
  if (!response.ok) { const error = new Error(data.message || '请求失败，请重试'); error.status = response.status; throw error }
  return data
}
