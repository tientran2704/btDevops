# Dockerfile (for LearnKing API - .NET)
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and projects' csproj (keeps layer caching)
COPY LearnKing.sln ./
COPY LearnKing.Application/*.csproj LearnKing.Application/
COPY LearnKing.Common/*.csproj LearnKing.Common/
COPY LearnKing.Domain/*.csproj LearnKing.Domain/
COPY LearnKing.Infrastructure/*.csproj LearnKing.Infrastructure/
COPY LearnKing.Api/*.csproj LearnKing.Api/

RUN dotnet restore LearnKing.sln

# Copy everything and publish
COPY . .
RUN dotnet publish LearnKing.Api/LearnKing.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy publish output
COPY --from=build /app/publish ./

# Environment
ENV ASPNETCORE_URLS=http://+:86 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Remove pdb and xml to reduce image size (optional)
RUN find /app -name "*.pdb" -delete && \
    find /app -name "*.xml" -delete || true

EXPOSE 86

ENTRYPOINT ["dotnet", "LearnKing.Api.dll"]
