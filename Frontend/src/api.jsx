
import axios from "axios";
const axiosInstance = axios.create({
    baseURL: "http://192.168.58.2:30519/api/",
});

export const UseAxios = () => {
  const token = localStorage.getItem("token"); 
  console.log(token);
  axiosInstance.interceptors.request.use(
    (config) => {
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
  );

  return{ axiosInstance}
};
