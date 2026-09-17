import { useAuthStore } from "@/store/auth.store";

export function usePermissions() {
  const user = useAuthStore((state) => state.user);

  const hasPermission = (permission: string | string[]) => {
    if (!user) return false;
    // Admins and owners bypass individual granular permissions
    if (
      user.role === "admin" ||
      user.role === "owner" ||
      user.permissions?.includes("admin") ||
      user.permissions?.includes("all")
    ) {
      return true;
    }

    const userPerms = user.permissions || [];
    if (Array.isArray(permission)) {
      return permission.some((p) => userPerms.includes(p));
    }
    return userPerms.includes(permission);
  };

  return {
    hasPermission,
    permissions: user?.permissions || [],
    isAdmin:
      user?.role === "admin" ||
      user?.role === "owner" ||
      user?.permissions?.includes("admin") ||
      user?.permissions?.includes("all"),
    isManager: user?.role === "manager" || user?.role === "branch_manager",
  };
}
