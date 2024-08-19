# 1. Base Image for Building:
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS installer-env
# This line sets the base image to the .NET SDK 8.0, which includes all the tools needed to build and publish a .NET application.

# 2. Copy Source Code:
COPY ./ /src
WORKDIR /src
# These lines copy all the files from your current directory on the host machine to the /src directory in the Docker image and set /src as the working directory.

# 3. Create Output Directory:
RUN mkdir /myAPI_Release
# This command creates a directory named /myAPI_Release where the published application will be stored.

# 4. Publish the Application:
RUN dotnet publish myAPI.csproj -c Release -r linux-x64 --self-contained true -o /myAPI_Release
# This command publishes the .NET application defined in myAPI.csproj in Release configuration for the linux-x64 runtime. The --self-contained true option means the application will include the .NET runtime, making it self-contained. The output is placed in the /myAPI_Release directory.

# 5. Base Image for Runtime:
FROM mcr.microsoft.com/dotnet/runtime:8.0
# This line sets the base image to the .NET runtime 8.0, which is lighter and only includes the runtime necessary to run the application.

# 6. Copy Published Application:
COPY --from=installer-env ["myAPI_Release", "/myAPI"]
WORKDIR /myAPI
# These lines copy the published application from the build stage (`installer-env`) to the `/myAPI` directory in the final image and set `/myAPI` as the working directory.

# 7. Create User:
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /myAPI
USER appuser
# These lines create a non-root user named `appuser` and set the ownership of the /myAPI directory to that user. This is a security best practice to run the application as a non-root user.

# 8. Set Environment Variable:
ENV ASPNETCORE_URLS=http://+:8080
# This sets the environment variable ASPNETCORE_URLS to http://+:8080, which tells the application to listen on port 8080.

# 9. Expose Port:
EXPOSE 8080
# This line informs Docker that the container will exposes port 8080 to allow external access to the application at runtime.

# 10. Set Entrypoint and Command:
CMD ["myAPI.dll"]
ENTRYPOINT [ "dotnet" ]
# These lines set the entry point of the container to the `dotnet` command and specify `myAPI.dll` as the argument. This means when the container starts, it will run `dotnet myAPI.dll`.
