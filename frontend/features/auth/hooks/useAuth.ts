import { useMutation } from "@tanstack/react-query";
import { loginApi, logoutApi, refreshApi } from "@/shared/lib/api/auth";
import type { LoginRequest, LoginResponse } from "@/shared/lib/api/auth";

export function useLogin() {
  return useMutation<LoginResponse, unknown, LoginRequest>({
    mutationFn: (data: LoginRequest) => loginApi(data),
  });
}

export function useLogout() {
  return useMutation({
    mutationFn: (refreshToken: string) => logoutApi(refreshToken),
  });
}

export function useRefresh() {
  return useMutation({
    mutationFn: (refreshToken: string) => refreshApi(refreshToken),
  });
}
