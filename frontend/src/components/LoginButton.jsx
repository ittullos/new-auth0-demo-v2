import { useAuth0 } from '@auth0/auth0-react'

export function LoginButton() {
  const { loginWithRedirect } = useAuth0()

  return (
    <button
      onClick={() => loginWithRedirect()}
      className="px-6 py-3 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-semibold rounded-xl shadow transition-colors duration-150 cursor-pointer"
    >
      Log In
    </button>
  )
}
