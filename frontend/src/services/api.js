import axios from 'axios'

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:9292'

export async function fetchProfile(accessToken) {
  const response = await axios.get(`${BASE_URL}/profile`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  })
  return response.data
}
