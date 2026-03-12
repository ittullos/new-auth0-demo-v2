import { useAuth0 } from '@auth0/auth0-react'

export function LogoutButton() {
  const { logout } = useAuth0()

  return (
    <button
      onClick={() => logout({ logoutParams: { returnTo: window.location.origin } })}
      className="px-4 py-2 bg-slate-100 hover:bg-slate-200 active:bg-slate-300 text-slate-700 font-medium rounded-lg text-sm transition-colors duration-150 cursor-pointer"
    >
      Log Out
    </button>
  )
}
