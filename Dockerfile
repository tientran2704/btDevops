# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and projects
COPY LearnKing.sln ./
COPY LearnKing.Application/*.csproj ./LearnKing.Application/
COPY LearnKing.Common/*.csproj ./LearnKing.Common/
COPY LearnKing.Domain/*.csproj ./LearnKing.Domain/
COPY LearnKing.Infrastructure/*.csproj ./LearnKing.Infrastructure/
COPY LearnKing.Api/*.csproj ./LearnKing.Api/

# Restore
RUN dotnet restore LearnKing.sln

# Copy all source code
COPY . .

# Publish
RUN dotnet publish LearnKing.Api/LearnKing.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:86
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Xoá file không cần thiết
RUN find /app -name "*.pdb" -delete && \
    find /app -name "*.xml" -delete

EXPOSE 86

# Run ứng dụng
ENTRYPOINT ["dotnet", "LearnKing.Api.dll"]
