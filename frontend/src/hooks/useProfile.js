import { useState, useEffect } from 'react'
import { useAuth0 } from '@auth0/auth0-react'
import { fetchProfile } from '../services/api'

export function useProfile() {
  const { getAccessTokenSilently, isAuthenticated } = useAuth0()
  const [profile, setProfile] = useState(null)
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!isAuthenticated) return

    let cancelled = false

    async function load() {
      setLoading(true)
      setError(null)
      try {
        const accessToken = await getAccessTokenSilently()
        const data = await fetchProfile(accessToken)
        if (!cancelled) {
          setProfile(data)
          setToken(accessToken)
        }
      } catch (err) {
        if (!cancelled) {
          const status = err.response?.status
          if (status === 401) {
            setError({ type: 'unauthorized', message: 'Your session is invalid or expired. Please log in again.' })
          } else {
            setError({ type: 'unknown', message: err.message || 'Something went wrong.' })
          }
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    load()
    return () => { cancelled = true }
  }, [isAuthenticated, getAccessTokenSilently])

  return { profile, token, loading, error }
}
