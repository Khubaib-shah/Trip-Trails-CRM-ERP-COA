import { useAuthStore } from "@/store/auth.store";

export function usePermissions() {
  const user = useAuthStore((state) => state.user);

  const hasPermission = (permission: string) => {
    if (!user) return false;
    // Admins, owners, and managers have full operational permissions (managers scoped to their own branch)
    if (
      user.role === "admin" ||
      user.role === "owner" ||
      user.role === "manager" ||
      user.role === "branch_manager"
    ) {
      return true;
    }
    if (user.permissions?.includes("admin") || user.permissions?.includes("all")) {
      return true;
    }
    return user.permissions?.includes(permission) ?? false;
  };

  return {
    hasPermission,
    permissions: user?.permissions || [],
    isAdmin: user?.role === "admin" || user?.role === "owner" || user?.permissions?.includes("admin"),
    isManager: user?.role === "manager" || user?.role === "branch_manager",
  };
}
